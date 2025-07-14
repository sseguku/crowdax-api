class Api::V1::CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_campaign, only: [:show, :update, :destroy]

  # GET /api/v1/campaigns
  def index
    authorize Campaign
    @campaigns = policy_scope(Campaign)
    render json: {
      status: { code: 200, message: 'Campaigns retrieved successfully.' },
      data: @campaigns.map { |campaign| CampaignSerializer.new(campaign).serializable_hash[:data][:attributes] }
    }
  end

  # GET /api/v1/campaigns/:id
  def show
    authorize @campaign
    render json: {
      status: { code: 200, message: 'Campaign retrieved successfully.' },
      data: CampaignSerializer.new(@campaign).serializable_hash[:data][:attributes]
    }
  end

  # POST /api/v1/campaigns
  def create
    @campaign = current_user.campaigns.build(campaign_params)
    authorize @campaign

    if @campaign.save
      render json: {
        status: { code: 201, message: 'Campaign created successfully.' },
        data: CampaignSerializer.new(@campaign).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: {
        status: { code: 422, message: 'Failed to create campaign.' },
        errors: @campaign.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/campaigns/:id
  def update
    authorize @campaign
    
    if @campaign.update(campaign_params)
      render json: {
        status: { code: 200, message: 'Campaign updated successfully.' },
        data: CampaignSerializer.new(@campaign).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: { code: 422, message: 'Failed to update campaign.' },
        errors: @campaign.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/campaigns/:id
  def destroy
    authorize @campaign
    @campaign.destroy
    render json: {
      status: { code: 200, message: 'Campaign deleted successfully.' }
    }
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: { code: 404, message: 'Campaign not found.' },
      errors: ['Campaign not found']
    }, status: :not_found
  end

  def campaign_params
    params.require(:campaign).permit(:title, :sector, :goal_amount, :team, :campaign_status, :pitch_deck)
  end
end
