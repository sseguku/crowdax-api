class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :email, :role, :created_at, :updated_at

  # Entrepreneur-specific attributes
  attributes :first_name, :last_name, :phone_number, :company_name, :industry, :business_stage,
             :founded_date, :website, :business_description, :problem_being_solved,
             :target_market, :competitive_advantage, :funding_amount_needed,
             :funding_purpose, :current_annual_revenue_min, :current_annual_revenue_max,
             :projected_annual_revenue_min, :projected_annual_revenue_max,
             :team_size_min, :team_size_max, :number_of_co_founders, :tin, :legal_structure

  # Investor-specific attributes
  attributes :job_title, :years_of_experience_min, :years_of_experience_max,
             :typical_investment_amount_min, :typical_investment_amount_max, :investment_frequency,
             :preferred_industries, :preferred_investment_stages, :annual_income_min, :annual_income_max,
             :net_worth_min, :net_worth_max, :accredited_investor, :risk_tolerance,
             :previous_investment_experience, :investment_goals, :minimum_investment, :maximum_investment,
             :terms_of_service_accepted, :privacy_policy_accepted, :terms_accepted_at, :privacy_accepted_at

  attribute :created_date do |user|
    user.created_at&.strftime('%d/%m/%Y')
  end

  attribute :full_name do |user|
    user.full_name
  end

  attribute :current_revenue_range do |user|
    user.current_revenue_range
  end

  attribute :projected_revenue_range do |user|
    user.projected_revenue_range
  end

  attribute :team_size_range do |user|
    user.team_size_range
  end

  attribute :years_in_business do |user|
    user.years_in_business
  end

  attribute :is_entrepreneur_registration_complete do |user|
    user.is_entrepreneur_registration_complete?
  end

  attribute :business_stage_display do |user|
    case user.business_stage
    when 'idea_stage'
      'Idea Stage'
    when 'mvp_development'
      'MVP Development'
    when 'early_traction'
      'Early Traction'
    when 'growth_stage'
      'Growth Stage'
    when 'scaling'
      'Scaling'
    when 'mature'
      'Mature'
    else
      user.business_stage&.titleize
    end
  end

  attribute :legal_structure_display do |user|
    case user.legal_structure
    when 'sole_proprietorship'
      'Sole Proprietorship'
    when 'partnership'
      'Partnership'
    when 'limited_liability_company'
      'Limited Liability Company'
    when 'corporation'
      'Corporation'
    when 'cooperative'
      'Cooperative'
    else
      user.legal_structure&.titleize
    end
  end

  attribute :industry_display do |user|
    user.industry&.titleize
  end

  # Investor-specific computed attributes
  attribute :years_of_experience_range do |user|
    user.years_of_experience_range
  end

  attribute :typical_investment_amount_range do |user|
    user.typical_investment_amount_range
  end

  attribute :annual_income_range do |user|
    user.annual_income_range
  end

  attribute :net_worth_range do |user|
    user.net_worth_range
  end

  attribute :investment_range do |user|
    user.investment_range
  end

  attribute :is_investor_registration_complete do |user|
    user.is_investor_registration_complete?
  end

  attribute :investment_frequency_display do |user|
    case user.investment_frequency
    when 'monthly'
      'Monthly'
    when 'quarterly'
      'Quarterly'
    when 'annually'
      'Annually'
    when 'occasionally'
      'Occasionally'
    else
      user.investment_frequency&.titleize
    end
  end

  attribute :risk_tolerance_display do |user|
    case user.risk_tolerance
    when 'conservative'
      'Conservative'
    when 'moderate'
      'Moderate'
    when 'aggressive'
      'Aggressive'
    else
      user.risk_tolerance&.titleize
    end
  end

  attribute :accredited_investor_display do |user|
    user.accredited_investor? ? 'Yes' : 'No'
  end
end 