class Api::V1::PublicController < ApplicationController
  skip_before_action :authenticate_user!

  # GET /api/v1/public/campaigns
  def campaigns
    campaigns = Campaign.running_campaigns.includes(:user)
    render json: {
      status: { code: 200, message: 'Live campaigns retrieved successfully.' },
      data: campaigns.map { |c| public_campaign_serializer(c) }
    }
  end

  # GET /api/v1/public/statistics
  def statistics
    render json: {
      status: { code: 200, message: 'Platform statistics retrieved successfully.' },
      data: {
        total_campaigns: Campaign.count,
        live_campaigns: Campaign.running_campaigns.count,
        total_investments: Investment.confirmed.count,
        total_raised: Campaign.sum(:raised_amount),
        total_deals: Campaign.funded.count,
        total_users: User.count
      }
    }
  end

  # GET /api/v1/public/metadata
  def metadata
    render json: {
      status: { code: 200, message: 'Platform metadata retrieved successfully.' },
      data: {
        terms_and_conditions_url: ENV['TERMS_AND_CONDITIONS_URL'] || 'https://example.com/terms',
        privacy_policy_url: ENV['PRIVACY_POLICY_URL'] || 'https://example.com/privacy',
        contact_email: ENV['CONTACT_EMAIL'] || 'support@example.com',
        contact_phone: ENV['CONTACT_PHONE'] || '+1234567890',
        platform_name: ENV['PLATFORM_NAME'] || 'Crowdax',
        platform_description: ENV['PLATFORM_DESCRIPTION'] || 'A platform for investing in innovative campaigns.'
      }
    }
  end

  private

  def public_campaign_serializer(campaign)
    {
      id: campaign.id,
      title: campaign.title,
      sector: campaign.sector,
      goal_amount: campaign.goal_amount,
      raised_amount: campaign.raised_amount,
      campaign_status: campaign.campaign_status,
      funding_progress: campaign.funding_progress,
      entrepreneur: {
        id: campaign.user.id,
        # Only public info
        first_name: campaign.user.try(:first_name),
        last_initial: campaign.user.try(:last_name)&.first,
      },
      created_at: campaign.created_at,
      updated_at: campaign.updated_at
    }
  end
end 