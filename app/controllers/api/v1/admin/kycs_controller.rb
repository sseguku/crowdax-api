class Api::V1::Admin::KycsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_kyc, only: [:show, :approve, :reject, :request_revision]

  # GET /api/v1/admin/kycs
  def index
    @kycs = Kyc.includes(:user)
    
    # Filter by status if provided
    if params[:status].present?
      @kycs = @kycs.where(status: params[:status])
    end

    # Filter by user role if provided
    if params[:user_role].present?
      @kycs = @kycs.joins(:user).where(users: { role: params[:user_role] })
    end

    # Filter by submission date
    if params[:submitted_after].present?
      @kycs = @kycs.where('created_at >= ?', params[:submitted_after])
    end

    if params[:submitted_before].present?
      @kycs = @kycs.where('created_at <= ?', params[:submitted_before])
    end

    # Order by different criteria
    case params[:order_by]
    when 'recent'
      @kycs = @kycs.order(created_at: :desc)
    when 'oldest'
      @kycs = @kycs.order(created_at: :asc)
    when 'status'
      @kycs = @kycs.order(:status, created_at: :desc)
    else
      @kycs = @kycs.order(created_at: :desc)
    end

    render json: {
      status: { code: 200, message: 'KYC submissions retrieved successfully.' },
      data: @kycs.map { |kyc| kyc_admin_serializer(kyc) }
    }
  end

  # GET /api/v1/admin/kycs/:id
  def show
    render json: {
      status: { code: 200, message: 'KYC details retrieved successfully.' },
      data: kyc_admin_serializer(@kyc)
    }
  end

  # POST /api/v1/admin/kycs/:id/approve
  def approve
    if @kyc.approved?
      render json: {
        status: { code: 422, message: 'KYC is already approved.' },
        errors: ['KYC is already approved']
      }, status: :unprocessable_entity
      return
    end

    @kyc.update!(status: 'approved')
    render json: {
      status: { code: 200, message: 'KYC approved successfully.' },
      data: kyc_admin_serializer(@kyc)
    }
  end

  # POST /api/v1/admin/kycs/:id/reject
  def reject
    if @kyc.rejected?
      render json: {
        status: { code: 422, message: 'KYC is already rejected.' },
        errors: ['KYC is already rejected']
      }, status: :unprocessable_entity
      return
    end

    @kyc.update!(status: 'rejected')
    render json: {
      status: { code: 200, message: 'KYC rejected successfully.' },
      data: kyc_admin_serializer(@kyc)
    }
  end

  # POST /api/v1/admin/kycs/:id/request_revision
  def request_revision
    if @kyc.under_review?
      render json: {
        status: { code: 422, message: 'KYC is already under review.' },
        errors: ['KYC is already under review']
      }, status: :unprocessable_entity
      return
    end

    @kyc.update!(status: 'under_review')
    render json: {
      status: { code: 200, message: 'KYC marked for revision successfully.' },
      data: kyc_admin_serializer(@kyc)
    }
  end

  private

  def set_kyc
    @kyc = Kyc.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: { code: 404, message: 'KYC not found.' },
      errors: ['KYC not found']
    }, status: :not_found
  end

  def require_admin!
    unless current_user.admin? || current_user.backadmin?
      render json: {
        status: { code: 403, message: 'Access denied. Admin privileges required.' },
        errors: ['Admin privileges required']
      }, status: :forbidden
    end
  end

  def kyc_admin_serializer(kyc)
    {
      id: kyc.id,
      status: kyc.status,
      id_number: kyc.id_number,
      phone: kyc.phone,
      address: kyc.address,
      created_at: kyc.created_at,
      updated_at: kyc.updated_at,
      documents_count: kyc.documents.count,
      user: {
        id: kyc.user.id,
        email: kyc.user.email,
        role: kyc.user.role,
        created_at: kyc.user.created_at
      },
      documents: kyc.documents.map do |document|
        {
          id: document.id,
          filename: document.filename,
          content_type: document.content_type,
          byte_size: document.byte_size,
          created_at: document.created_at
        }
      end,
      can_be_approved: kyc.pending? || kyc.under_review?,
      can_be_rejected: kyc.pending? || kyc.under_review?,
      can_request_revision: kyc.pending?
    }
  end
end 