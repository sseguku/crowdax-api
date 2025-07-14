class Api::V1::KycsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_kyc, only: [:show, :update, :destroy]

  # GET /api/v1/kycs
  def index
    authorize Kyc
    @kycs = policy_scope(Kyc).includes(:user)
    render json: {
      status: { code: 200, message: 'KYC submissions retrieved successfully.' },
      data: @kycs.map { |kyc| KycSerializer.new(kyc, { params: { current_user: current_user } }).serializable_hash[:data][:attributes] }
    }
  end

  # GET /api/v1/kycs/:id
  def show
    authorize @kyc
    render json: {
      status: { code: 200, message: 'KYC details retrieved successfully.' },
      data: KycSerializer.new(@kyc, { params: { current_user: current_user } }).serializable_hash[:data][:attributes]
    }
  end

  # POST /api/v1/kycs
  def create
    @kyc = current_user.build_kyc(kyc_params)
    authorize @kyc

    if @kyc.save
      render json: {
        status: { code: 201, message: 'KYC submission created successfully.' },
        data: KycSerializer.new(@kyc, { params: { current_user: current_user } }).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: {
        status: { code: 422, message: 'Failed to create KYC submission.' },
        errors: @kyc.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/kycs/:id
  def update
    authorize @kyc
    
    if @kyc.update(kyc_params)
      render json: {
        status: { code: 200, message: 'KYC submission updated successfully.' },
        data: KycSerializer.new(@kyc, { params: { current_user: current_user } }).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: { code: 422, message: 'Failed to update KYC submission.' },
        errors: @kyc.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/kycs/:id
  def destroy
    authorize @kyc
    @kyc.destroy
    render json: {
      status: { code: 200, message: 'KYC submission deleted successfully.' }
    }
  end

  # POST /api/v1/kycs/:id/approve
  def approve
    authorize @kyc, :approve?
    
    if @kyc.update(status: 'approved')
      render json: {
        status: { code: 200, message: 'KYC approved successfully.' },
        data: KycSerializer.new(@kyc, { params: { current_user: current_user } }).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: { code: 422, message: 'Failed to approve KYC.' },
        errors: @kyc.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_kyc
    @kyc = Kyc.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: { code: 404, message: 'KYC submission not found.' },
      errors: ['KYC submission not found']
    }, status: :not_found
  end

  def kyc_params
    params.require(:kyc).permit(:id_number, :phone, :address, :documents)
  end
end
