class Api::V1::Admin::InvestorsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_investor, only: [:show, :approve, :reject]

  # GET /api/v1/admin/investors
  def index
    @investors = User.investor.includes(:investments, :invested_campaigns)
    
    # Filter by investment status if provided
    if params[:investment_status].present?
      case params[:investment_status]
      when 'has_investments'
        @investors = @investors.joins(:investments).distinct
      when 'no_investments'
        @investors = @investors.left_joins(:investments).where(investments: { id: nil })
      when 'confirmed_investments'
        @investors = @investors.joins(:investments).where(investments: { status: 'confirmed' }).distinct
      end
    end

    # Filter by total investment amount
    if params[:min_investment].present?
      @investors = @investors.joins(:investments)
                            .where(investments: { status: 'confirmed' })
                            .group('users.id')
                            .having('SUM(investments.amount) >= ?', params[:min_investment].to_f)
    end

    render json: {
      status: { code: 200, message: 'Investors retrieved successfully.' },
      data: @investors.map { |investor| investor_admin_serializer(investor) }
    }
  end

  # GET /api/v1/admin/investors/:id
  def show
    render json: {
      status: { code: 200, message: 'Investor details retrieved successfully.' },
      data: investor_admin_serializer(@investor)
    }
  end

  # POST /api/v1/admin/investors/:id/approve
  def approve
    if @investor.role != 'investor'
      render json: {
        status: { code: 422, message: 'User is not an investor.' },
        errors: ['User is not an investor']
      }, status: :unprocessable_entity
      return
    end

    # For now, we'll just ensure the user has investor role
    # In a real system, you might have additional approval logic
    render json: {
      status: { code: 200, message: 'Investor approved successfully.' },
      data: investor_admin_serializer(@investor)
    }
  end

  # POST /api/v1/admin/investors/:id/reject
  def reject
    if @investor.role != 'investor'
      render json: {
        status: { code: 422, message: 'User is not an investor.' },
        errors: ['User is not an investor']
      }, status: :unprocessable_entity
      return
    end

    @investor.update!(role: 'visitor')
    render json: {
      status: { code: 200, message: 'Investor rejected successfully.' },
      data: investor_admin_serializer(@investor)
    }
  end

  private

  def set_investor
    @investor = User.investor.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: { code: 404, message: 'Investor not found.' },
      errors: ['Investor not found']
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

  def investor_admin_serializer(investor)
    {
      id: investor.id,
      email: investor.email,
      role: investor.role,
      created_at: investor.created_at,
      updated_at: investor.updated_at,
      total_investments: investor.investments.count,
      confirmed_investments: investor.investments.confirmed.count,
      total_invested_amount: investor.total_invested_amount,
      invested_campaigns_count: investor.invested_campaigns.count,
      average_investment_amount: investor.investments.confirmed.average(:amount)&.round(2),
      last_investment_date: investor.investments.confirmed.maximum(:created_at),
      investments: investor.investments.confirmed.includes(:campaign).map do |investment|
        {
          id: investment.id,
          amount: investment.amount,
          status: investment.status,
          created_at: investment.created_at,
          campaign: {
            id: investment.campaign.id,
            title: investment.campaign.title,
            sector: investment.campaign.sector,
            campaign_status: investment.campaign.campaign_status
          }
        }
      end
    }
  end
end 