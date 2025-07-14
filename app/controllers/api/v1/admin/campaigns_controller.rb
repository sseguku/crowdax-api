class Api::V1::Admin::CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_campaign, only: [:show, :approve, :reject]

  # GET /api/v1/admin/campaigns
  def index
    @campaigns = Campaign.includes(:user, :investments, :investors)
    
    # Filter by status if provided
    if params[:status].present?
      @campaigns = @campaigns.where(campaign_status: params[:status])
    end

    # Filter by sector if provided
    if params[:sector].present?
      @campaigns = @campaigns.where(sector: params[:sector])
    end

    # Filter by funding progress
    if params[:funding_progress].present?
      case params[:funding_progress]
      when 'nearly_funded'
        @campaigns = @campaigns.nearly_funded
      when 'fully_funded'
        @campaigns = @campaigns.fully_funded
      when 'under_50_percent'
        @campaigns = @campaigns.where('(current_amount / goal_amount) < 0.5')
      end
    end

    # Filter by goal amount range
    if params[:min_goal].present?
      @campaigns = @campaigns.with_goal_above(params[:min_goal].to_f)
    end

    if params[:max_goal].present?
      @campaigns = @campaigns.with_goal_below(params[:max_goal].to_f)
    end

    # Order by different criteria
    case params[:order_by]
    when 'recent'
      @campaigns = @campaigns.order(created_at: :desc)
    when 'funding_progress'
      @campaigns = @campaigns.order('(current_amount / goal_amount) DESC')
    when 'goal_amount'
      @campaigns = @campaigns.order(goal_amount: :desc)
    when 'current_amount'
      @campaigns = @campaigns.order(current_amount: :desc)
    else
      @campaigns = @campaigns.order(created_at: :desc)
    end

    render json: {
      status: { code: 200, message: 'Campaigns retrieved successfully.' },
      data: @campaigns.map { |campaign| campaign_admin_serializer(campaign) }
    }
  end

  # GET /api/v1/admin/campaigns/:id
  def show
    render json: {
      status: { code: 200, message: 'Campaign details retrieved successfully.' },
      data: campaign_admin_serializer(@campaign)
    }
  end

  # POST /api/v1/admin/campaigns/:id/approve
  def approve
    if @campaign.approved?
      render json: {
        status: { code: 422, message: 'Campaign is already approved.' },
        errors: ['Campaign is already approved']
      }, status: :unprocessable_entity
      return
    end

    if @campaign.submitted?
      @campaign.update!(campaign_status: 'approved')
      render json: {
        status: { code: 200, message: 'Campaign approved successfully.' },
        data: campaign_admin_serializer(@campaign)
      }
    else
      render json: {
        status: { code: 422, message: 'Campaign must be submitted before approval.' },
        errors: ['Campaign must be in submitted status']
      }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/admin/campaigns/:id/reject
  def reject
    if @campaign.rejected?
      render json: {
        status: { code: 422, message: 'Campaign is already rejected.' },
        errors: ['Campaign is already rejected']
      }, status: :unprocessable_entity
      return
    end

    if @campaign.submitted?
      @campaign.update!(campaign_status: 'rejected')
      render json: {
        status: { code: 200, message: 'Campaign rejected successfully.' },
        data: campaign_admin_serializer(@campaign)
      }
    else
      render json: {
        status: { code: 422, message: 'Campaign must be submitted before rejection.' },
        errors: ['Campaign must be in submitted status']
      }, status: :unprocessable_entity
    end
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

  def require_admin!
    unless current_user.admin? || current_user.backadmin?
      render json: {
        status: { code: 403, message: 'Access denied. Admin privileges required.' },
        errors: ['Admin privileges required']
      }, status: :forbidden
    end
  end

  def campaign_admin_serializer(campaign)
    {
      id: campaign.id,
      title: campaign.title,
      sector: campaign.sector,
      goal_amount: campaign.goal_amount,
      current_amount: campaign.current_amount,
      campaign_status: campaign.campaign_status,
      funding_progress: campaign.funding_progress,
      team: campaign.team,
      created_at: campaign.created_at,
      updated_at: campaign.updated_at,
      entrepreneur: {
        id: campaign.user.id,
        email: campaign.user.email,
        kyc_status: campaign.user.kyc&.status || 'not_submitted',
        kyc_verified: campaign.user.kyc_verified?
      },
      investments_summary: {
        total_investments: campaign.investments.count,
        confirmed_investments: campaign.investments.confirmed.count,
        total_investors: campaign.total_investors_count,
        average_investment: campaign.investments.confirmed.average(:amount)&.round(2)
      },
      can_be_approved: campaign.submitted? && campaign.user.kyc_verified?,
      can_be_rejected: campaign.submitted?
    }
  end
end 