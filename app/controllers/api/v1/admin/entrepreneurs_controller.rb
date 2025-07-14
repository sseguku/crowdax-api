class Api::V1::Admin::EntrepreneursController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entrepreneur, only: [:show, :approve, :reject, :deactivate]

  # GET /api/v1/admin/entrepreneurs
  def index
    authorize User, :index?
    @entrepreneurs = User.entrepreneur.includes(:kyc, :campaigns)
    
    # Filter by status if provided
    if params[:status].present?
      case params[:status]
      when 'kyc_verified'
        @entrepreneurs = @entrepreneurs.joins(:kyc).where(kycs: { status: 'approved' })
      when 'kyc_pending'
        @entrepreneurs = @entrepreneurs.joins(:kyc).where(kycs: { status: 'pending' })
      when 'kyc_rejected'
        @entrepreneurs = @entrepreneurs.joins(:kyc).where(kycs: { status: 'rejected' })
      when 'no_kyc'
        @entrepreneurs = @entrepreneurs.left_joins(:kyc).where(kycs: { id: nil })
      end
    end

    # Filter by campaign status if provided
    if params[:has_campaigns].present?
      case params[:has_campaigns]
      when 'true'
        @entrepreneurs = @entrepreneurs.joins(:campaigns)
      when 'false'
        @entrepreneurs = @entrepreneurs.left_joins(:campaigns).where(campaigns: { id: nil })
      end
    end

    render json: {
      status: { code: 200, message: 'Entrepreneurs retrieved successfully.' },
      data: @entrepreneurs.map { |entrepreneur| entrepreneur_admin_serializer(entrepreneur) }
    }
  end

  # GET /api/v1/admin/entrepreneurs/:id
  def show
    authorize @entrepreneur, :show?
    render json: {
      status: { code: 200, message: 'Entrepreneur details retrieved successfully.' },
      data: entrepreneur_admin_serializer(@entrepreneur)
    }
  end

  # POST /api/v1/admin/entrepreneurs/:id/approve
  def approve
    authorize @entrepreneur, :update?
    if @entrepreneur.kyc&.approved?
      render json: {
        status: { code: 422, message: 'Entrepreneur is already approved.' },
        errors: ['Entrepreneur KYC is already approved']
      }, status: :unprocessable_entity
      return
    end

    if @entrepreneur.kyc
      @entrepreneur.kyc.update!(status: 'approved')
      render json: {
        status: { code: 200, message: 'Entrepreneur approved successfully.' },
        data: entrepreneur_admin_serializer(@entrepreneur)
      }
    else
      render json: {
        status: { code: 422, message: 'Cannot approve entrepreneur without KYC.' },
        errors: ['Entrepreneur has no KYC submission']
      }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/admin/entrepreneurs/:id/reject
  def reject
    authorize @entrepreneur, :update?
    if @entrepreneur.kyc&.rejected?
      render json: {
        status: { code: 422, message: 'Entrepreneur is already rejected.' },
        errors: ['Entrepreneur KYC is already rejected']
      }, status: :unprocessable_entity
      return
    end

    if @entrepreneur.kyc
      @entrepreneur.kyc.update!(status: 'rejected')
      render json: {
        status: { code: 200, message: 'Entrepreneur rejected successfully.' },
        data: entrepreneur_admin_serializer(@entrepreneur)
      }
    else
      render json: {
        status: { code: 422, message: 'Cannot reject entrepreneur without KYC.' },
        errors: ['Entrepreneur has no KYC submission']
      }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/admin/entrepreneurs/:id/deactivate
  def deactivate
    authorize @entrepreneur, :update?
    if @entrepreneur.role != 'entrepreneur'
      render json: {
        status: { code: 422, message: 'User is not an entrepreneur.' },
        errors: ['User is not an entrepreneur']
      }, status: :unprocessable_entity
      return
    end

    @entrepreneur.update!(role: 'visitor')
    render json: {
      status: { code: 200, message: 'Entrepreneur deactivated successfully.' },
      data: entrepreneur_admin_serializer(@entrepreneur)
    }
  end

  private

  def set_entrepreneur
    @entrepreneur = User.entrepreneur.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: { code: 404, message: 'Entrepreneur not found.' },
      errors: ['Entrepreneur not found']
    }, status: :not_found
  end

  def entrepreneur_admin_serializer(entrepreneur)
    {
      id: entrepreneur.id,
      email: entrepreneur.email,
      role: entrepreneur.role,
      created_at: entrepreneur.created_at,
      updated_at: entrepreneur.updated_at,
      kyc_status: entrepreneur.kyc&.status || 'not_submitted',
      kyc_verified: entrepreneur.kyc_verified?,
      campaigns_count: entrepreneur.campaigns.count,
      active_campaigns_count: entrepreneur.campaigns.where(campaign_status: ['approved', 'funded']).count,
      total_funding_raised: entrepreneur.campaigns.sum(:current_amount),
      kyc: entrepreneur.kyc ? {
        id: entrepreneur.kyc.id,
        status: entrepreneur.kyc.status,
        id_number: entrepreneur.kyc.id_number,
        phone: entrepreneur.kyc.phone,
        address: entrepreneur.kyc.address,
        created_at: entrepreneur.kyc.created_at,
        updated_at: entrepreneur.kyc.updated_at
      } : nil
    }
  end
end 