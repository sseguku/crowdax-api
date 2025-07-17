class Api::V1::PublicController < ApplicationController

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
        platform_description: ENV['PLATFORM_DESCRIPTION'] || 'A platform for investing in innovative campaigns.',
        # Entrepreneur registration options
        business_stages: User::BUSINESS_STAGES,
        legal_structures: User::LEGAL_STRUCTURES,
        industries: User::INDUSTRIES,
        # Investor registration options
        investment_frequencies: User::INVESTMENT_FREQUENCIES,
        risk_tolerances: User::RISK_TOLERANCES,
        investment_stages: User::INVESTMENT_STAGES
      }
    }
  end

  # POST /api/v1/public/entrepreneur_registration
  def entrepreneur_registration
    # Create user with entrepreneur role
    user = User.new(entrepreneur_registration_params)
    user.role = 'entrepreneur'
    
    if user.save
      # Log registration
      audit_service = AuditLoggingService.new(request, user)
      audit_service.log_registration('entrepreneur_registration')
      
      render json: {
        status: { 
          code: 200, 
          message: 'Entrepreneur registration successful. Please check your email to confirm your account.' 
        },
        data: {
          user: UserSerializer.new(user).serializable_hash[:data][:attributes]
        }
      }
    else
      render json: {
        status: { 
          code: 422, 
          message: 'Entrepreneur registration failed.' 
        },
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/public/investor_registration
  def investor_registration
    # Create user with investor role
    user = User.new(investor_registration_params)
    user.role = 'investor'
    
    if user.save
      # Log registration
      audit_service = AuditLoggingService.new(request, user)
      audit_service.log_registration('investor_registration')
      
      render json: {
        status: { 
          code: 200, 
          message: 'Investor registration successful. Please check your email to confirm your account.' 
        },
        data: {
          user: UserSerializer.new(user).serializable_hash[:data][:attributes]
        }
      }
    else
      render json: {
        status: { 
          code: 422, 
          message: 'Investor registration failed.' 
        },
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def entrepreneur_registration_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      :first_name, :last_name, :phone_number, :company_name, :industry, :business_stage,
      :founded_date, :website, :business_description, :problem_being_solved,
      :target_market, :competitive_advantage, :funding_amount_needed,
      :funding_purpose, :current_annual_revenue_min, :current_annual_revenue_max,
      :projected_annual_revenue_min, :projected_annual_revenue_max,
      :team_size_min, :team_size_max, :number_of_co_founders, :tin, :legal_structure
    )
  end

  def investor_registration_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      :first_name, :last_name, :phone_number, :company_name, :job_title, :industry,
      :years_of_experience_min, :years_of_experience_max, :typical_investment_amount_min,
      :typical_investment_amount_max, :investment_frequency, :preferred_industries,
      :preferred_investment_stages, :annual_income_min, :annual_income_max,
      :net_worth_min, :net_worth_max, :accredited_investor, :risk_tolerance,
      :previous_investment_experience, :investment_goals, :minimum_investment,
      :maximum_investment, :terms_of_service_accepted, :privacy_policy_accepted
    )
  end

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