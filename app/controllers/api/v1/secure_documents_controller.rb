class Api::V1::SecureDocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_kyc
  before_action :authorize_document_access

  # GET /api/v1/kycs/:kyc_id/documents/:id
  def show
    document = @kyc.documents.find(params[:id])
    
    # Check if document is encrypted
    if document.blob.metadata['encrypted']
      # Decrypt the document
      decrypted_attachment = @kyc.decrypt_attachment(document)
      
      if decrypted_attachment
        send_data decrypted_attachment.download,
                  filename: decrypted_attachment.filename.to_s,
                  type: decrypted_attachment.content_type,
                  disposition: 'attachment'
      else
        render json: {
          status: { code: 500, message: 'Failed to decrypt document.' },
          errors: ['Document decryption failed']
        }, status: :internal_server_error
      end
    else
      # Document is not encrypted, serve normally
      send_data document.download,
                filename: document.filename.to_s,
                type: document.content_type,
                disposition: 'attachment'
    end
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: { code: 404, message: 'Document not found.' },
      errors: ['Document not found']
    }, status: :not_found
  end

  private

  def set_kyc
    @kyc = Kyc.find(params[:kyc_id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: { code: 404, message: 'KYC submission not found.' },
      errors: ['KYC submission not found']
    }, status: :not_found
  end

  def authorize_document_access
    # Only allow access to the KYC owner or admins
    unless current_user.admin? || current_user.id == @kyc.user_id
      render json: {
        status: { code: 403, message: 'Access denied.' },
        errors: ['You are not authorized to access this document']
      }, status: :forbidden
    end
  end
end 