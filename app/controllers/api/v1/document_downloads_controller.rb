class Api::V1::DocumentDownloadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_campaign
  before_action :authorize_document_access!

  # GET /api/v1/campaigns/:campaign_id/documents/:document_type
  def show
    case params[:document_type]
    when 'pitch_deck'
      download_pitch_deck
    when 'kyc_documents'
      download_kyc_documents
    else
      render json: {
        status: { code: 400, message: 'Invalid document type.' },
        errors: ['Document type not supported']
      }, status: :bad_request
    end
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:campaign_id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: { code: 404, message: 'Campaign not found.' },
      errors: ['Campaign not found']
    }, status: :not_found
  end

  def authorize_document_access!
    # Allow campaign owner to access documents
    return if @campaign.user_id == current_user.id
    
    # Allow admins to access documents
    return if current_user.admin? || current_user.backadmin?
    
    # Check if user is a confirmed investor in this campaign
    unless @campaign.has_confirmed_investor?(current_user)
      render json: {
        status: { code: 403, message: 'Access denied. Only confirmed investors can download documents.' },
        errors: ['You must be a confirmed investor to access campaign documents']
      }, status: :forbidden
    end
  end

  def download_pitch_deck
    if @campaign.pitch_deck.attached?
      # Set secure headers
      response.headers['Content-Disposition'] = "attachment; filename=\"#{@campaign.title.parameterize}_pitch_deck.pdf\""
      response.headers['X-Content-Type-Options'] = 'nosniff'
      response.headers['X-Frame-Options'] = 'DENY'
      
      # Stream the file securely
      send_data @campaign.pitch_deck.download, 
                type: @campaign.pitch_deck.content_type, 
                disposition: 'attachment'
    else
      render json: {
        status: { code: 404, message: 'Pitch deck not found.' },
        errors: ['Pitch deck not available']
      }, status: :not_found
    end
  end

  def download_kyc_documents
    # Only campaign owner and admins can access KYC documents
    unless @campaign.user_id == current_user.id || current_user.admin? || current_user.backadmin?
      render json: {
        status: { code: 403, message: 'Access denied. Only campaign owner and admins can access KYC documents.' },
        errors: ['You are not authorized to access KYC documents']
      }, status: :forbidden
      return
    end

    kyc = @campaign.user.kyc
    if kyc&.documents&.attached?
      # Create a zip file with all KYC documents
      require 'zip'
      
      zip_data = Zip::OutputStream.write_buffer do |zos|
        kyc.documents.each_with_index do |document, index|
          filename = "kyc_document_#{index + 1}_#{document.filename}"
          zos.put_next_entry(filename)
          zos.write(document.download)
        end
      end
      
      # Set secure headers
      response.headers['Content-Disposition'] = "attachment; filename=\"#{@campaign.user.email}_kyc_documents.zip\""
      response.headers['X-Content-Type-Options'] = 'nosniff'
      response.headers['X-Frame-Options'] = 'DENY'
      
      send_data zip_data.string, 
                type: 'application/zip', 
                disposition: 'attachment'
    else
      render json: {
        status: { code: 404, message: 'KYC documents not found.' },
        errors: ['KYC documents not available']
      }, status: :not_found
    end
  end
end 