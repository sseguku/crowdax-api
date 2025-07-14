class Api::V1::Admin::DashboardController < ApplicationController
  before_action :authenticate_user!

  # GET /api/v1/admin/dashboard
  def index
    authorize current_user, :admin_dashboard?
    render json: {
      status: { code: 200, message: 'Dashboard metrics retrieved successfully.' },
      data: {
        overview: overview_metrics,
        campaigns: campaign_metrics,
        users: user_metrics,
        investments: investment_metrics,
        top_performers: top_performers_metrics,
        recent_activity: recent_activity_metrics
      }
    }
  end

  private

  def overview_metrics
    {
      total_campaigns: Campaign.count,
      total_users: User.count,
      total_investments: Investment.count,
      total_funding_raised: Campaign.sum(:current_amount),
      active_campaigns: Campaign.active.count,
      pending_approvals: {
        campaigns: Campaign.submitted.count,
        entrepreneurs: User.entrepreneur.joins(:kyc).where(kycs: { status: 'pending' }).count,
        kycs: Kyc.pending.count
      }
    }
  end

  def campaign_metrics
    {
      by_status: Campaign.group(:campaign_status).count,
      by_sector: Campaign.group(:sector).count,
      funding_progress: {
        nearly_funded: Campaign.nearly_funded.count,
        fully_funded: Campaign.fully_funded.count,
        under_50_percent: Campaign.where('(current_amount / goal_amount) < 0.5').count
      },
      recent_campaigns: Campaign.recent(5).map do |campaign|
        {
          id: campaign.id,
          title: campaign.title,
          sector: campaign.sector,
          goal_amount: campaign.goal_amount,
          current_amount: campaign.current_amount,
          funding_progress: campaign.funding_progress,
          status: campaign.campaign_status,
          created_at: campaign.created_at
        }
      end
    }
  end

  def user_metrics
    {
      by_role: User.group(:role).count,
      entrepreneurs: {
        total: User.entrepreneur.count,
        kyc_verified: User.entrepreneur.joins(:kyc).where(kycs: { status: 'approved' }).count,
        kyc_pending: User.entrepreneur.joins(:kyc).where(kycs: { status: 'pending' }).count,
        kyc_rejected: User.entrepreneur.joins(:kyc).where(kycs: { status: 'rejected' }).count,
        no_kyc: User.entrepreneur.left_joins(:kyc).where(kycs: { id: nil }).count
      },
      investors: {
        total: User.investor.count,
        with_investments: User.investor.joins(:investments).distinct.count,
        without_investments: User.investor.left_joins(:investments).where(investments: { id: nil }).count
      },
      recent_signups: User.order(created_at: :desc).limit(10).map do |user|
        {
          id: user.id,
          email: user.email,
          role: user.role,
          created_at: user.created_at
        }
      end
    }
  end

  def investment_metrics
    {
      total_amount: Investment.confirmed.sum(:amount),
      average_investment: Investment.confirmed.average(:amount)&.round(2),
      by_status: Investment.group(:status).count,
      recent_investments: Investment.confirmed.includes(:user, :campaign).order(created_at: :desc).limit(10).map do |investment|
        {
          id: investment.id,
          amount: investment.amount,
          status: investment.status,
          created_at: investment.created_at,
          investor: {
            id: investment.user.id,
            email: investment.user.email
          },
          campaign: {
            id: investment.campaign.id,
            title: investment.campaign.title,
            sector: investment.campaign.sector
          }
        }
      end
    }
  end

  def top_performers_metrics
    {
      top_campaigns: Campaign.top_funded(5).map do |campaign|
        {
          id: campaign.id,
          title: campaign.title,
          sector: campaign.sector,
          goal_amount: campaign.goal_amount,
          current_amount: campaign.current_amount,
          funding_progress: campaign.funding_progress,
          investors_count: campaign.total_investors_count
        }
      end,
      top_investors: User.investor.joins(:investments)
                        .where(investments: { status: 'confirmed' })
                        .group('users.id')
                        .order('SUM(investments.amount) DESC')
                        .limit(5)
                        .map do |user|
        {
          id: user.id,
          email: user.email,
          total_invested: user.total_invested_amount,
          investments_count: user.investments.confirmed.count,
          average_investment: user.investments.confirmed.average(:amount)&.round(2)
        }
      end,
      top_entrepreneurs: User.entrepreneur.joins(:campaigns)
                             .group('users.id')
                             .order('SUM(campaigns.current_amount) DESC')
                             .limit(5)
                             .map do |user|
        {
          id: user.id,
          email: user.email,
          total_raised: user.campaigns.sum(:current_amount),
          campaigns_count: user.campaigns.count,
          kyc_status: user.kyc&.status || 'not_submitted'
        }
      end
    }
  end

  def recent_activity_metrics
    {
      recent_campaigns: Campaign.order(created_at: :desc).limit(5).map do |campaign|
        {
          id: campaign.id,
          title: campaign.title,
          status: campaign.campaign_status,
          created_at: campaign.created_at,
          entrepreneur: campaign.user.email
        }
      end,
      recent_investments: Investment.confirmed.includes(:user, :campaign).order(created_at: :desc).limit(5).map do |investment|
        {
          id: investment.id,
          amount: investment.amount,
          created_at: investment.created_at,
          investor: investment.user.email,
          campaign: investment.campaign.title
        }
      end,
      recent_kyc_submissions: Kyc.order(created_at: :desc).limit(5).map do |kyc|
        {
          id: kyc.id,
          status: kyc.status,
          created_at: kyc.created_at,
          user: kyc.user.email,
          user_role: kyc.user.role
        }
      end
    }
  end
end 