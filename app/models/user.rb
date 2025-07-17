class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  enum :role, { entrepreneur: 0, investor: 1, admin: 2, visitor: 3, backadmin: 4 }

  # Associations
  has_one :kyc, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  has_many :investments, dependent: :destroy
  has_many :invested_campaigns, through: :investments, source: :campaign

  # Validations
  validates :first_name, :last_name, presence: true, if: :entrepreneur?
  validates :company_name, :industry, :business_stage, :founded_date, 
            :business_description, :problem_being_solved, :target_market, 
            :competitive_advantage, :funding_purpose, :tin, :legal_structure, 
            :phone_number, presence: true, if: :entrepreneur?
  validates :funding_amount_needed, :current_annual_revenue_min, :current_annual_revenue_max,
            :projected_annual_revenue_min, :projected_annual_revenue_max,
            :team_size_min, :team_size_max, :number_of_co_founders,
            presence: true, if: :entrepreneur?
  
  # Investor validations
  validates :first_name, :last_name, :phone_number, presence: true, if: :investor?
  validates :company_name, :job_title, :industry, presence: true, if: :investor?
  validates :years_of_experience_min, :years_of_experience_max, presence: true, if: :investor?
  validates :typical_investment_amount_min, :typical_investment_amount_max, :investment_frequency,
            :preferred_industries, :preferred_investment_stages, presence: true, if: :investor?
  validates :annual_income_min, :annual_income_max, :net_worth_min, :net_worth_max,
            :risk_tolerance, :minimum_investment, :maximum_investment, presence: true, if: :investor?
  validates :terms_of_service_accepted, :privacy_policy_accepted, inclusion: { in: [true] }, if: :investor?
  
  validates :website, format: { with: URI::regexp(%w[http https]), allow_blank: true }
  validates :phone_number, format: { with: /\A\+?[\d\s\-\(\)]{10,}\z/, allow_blank: true }, if: :entrepreneur?
  validates :phone_number, format: { with: /\A\+?[\d\s\-\(\)]{10,}\z/, allow_blank: true }, if: :investor?
  validates :funding_amount_needed, numericality: { greater_than: 0 }, if: :entrepreneur?
  validates :current_annual_revenue_min, :current_annual_revenue_max,
            :projected_annual_revenue_min, :projected_annual_revenue_max,
            numericality: { greater_than_or_equal_to: 0 }, if: :entrepreneur?
  validates :team_size_min, :team_size_max, :number_of_co_founders,
            numericality: { greater_than: 0, only_integer: true }, if: :entrepreneur?
  validates :team_size_max, numericality: { greater_than_or_equal_to: :team_size_min }, if: :entrepreneur?
  validates :current_annual_revenue_max, numericality: { greater_than_or_equal_to: :current_annual_revenue_min }, if: :entrepreneur?
  validates :projected_annual_revenue_max, numericality: { greater_than_or_equal_to: :projected_annual_revenue_min }, if: :entrepreneur?
  validates :founded_date, presence: true, if: :entrepreneur?
  validate :founded_date_cannot_be_in_future, if: :entrepreneur?
  
  # Investor-specific validations
  validates :years_of_experience_min, :years_of_experience_max,
            numericality: { greater_than_or_equal_to: 0, only_integer: true }, if: :investor?
  validates :years_of_experience_max, numericality: { greater_than_or_equal_to: :years_of_experience_min }, if: :investor?
  validates :typical_investment_amount_min, :typical_investment_amount_max,
            :annual_income_min, :annual_income_max, :net_worth_min, :net_worth_max,
            :minimum_investment, :maximum_investment,
            numericality: { greater_than: 0 }, if: :investor?
  validates :typical_investment_amount_max, numericality: { greater_than_or_equal_to: :typical_investment_amount_min }, if: :investor?
  validates :annual_income_max, numericality: { greater_than_or_equal_to: :annual_income_min }, if: :investor?
  validates :net_worth_max, numericality: { greater_than_or_equal_to: :net_worth_min }, if: :investor?
  validates :maximum_investment, numericality: { greater_than_or_equal_to: :minimum_investment }, if: :investor?
  validates :investment_frequency, inclusion: { in: %w[monthly quarterly annually occasionally] }, if: :investor?
  validates :risk_tolerance, inclusion: { in: %w[conservative moderate aggressive] }, if: :investor?
  validates :preferred_industries, length: { minimum: 1, message: "must select at least one industry" }, if: :investor?
  validates :preferred_investment_stages, length: { minimum: 1, message: "must select at least one investment stage" }, if: :investor?

  # Business stage options
  BUSINESS_STAGES = [
    'idea_stage',
    'mvp_development',
    'early_traction',
    'growth_stage',
    'scaling',
    'mature'
  ].freeze

  # Legal structure options
  LEGAL_STRUCTURES = [
    'sole_proprietorship',
    'partnership',
    'limited_liability_company',
    'corporation',
    'cooperative',
    'other'
  ].freeze

  # Industry options
  INDUSTRIES = [
    'technology',
    'healthcare',
    'finance',
    'education',
    'retail',
    'manufacturing',
    'agriculture',
    'energy',
    'transportation',
    'real_estate',
    'entertainment',
    'food_beverage',
    'fashion',
    'sports',
    'other'
  ].freeze

  # Investment frequency options
  INVESTMENT_FREQUENCIES = [
    'monthly',
    'quarterly',
    'annually',
    'occasionally'
  ].freeze

  # Risk tolerance options
  RISK_TOLERANCES = [
    'conservative',
    'moderate',
    'aggressive'
  ].freeze

  # Investment stages options
  INVESTMENT_STAGES = [
    'idea_stage',
    'mvp_prototype',
    'early_revenue',
    'growth_stage',
    'scaling'
  ].freeze

  # Consent logic
  def consent_given?
    consent_given_at.present? && (consent_withdrawn_at.nil? || consent_given_at > consent_withdrawn_at)
  end

  def give_consent!(version = nil)
    update!(consent_given_at: Time.current, consent_withdrawn_at: nil, consent_version: version)
  end

  def withdraw_consent!
    update!(consent_withdrawn_at: Time.current)
  end

  # Instance methods
  def kyc_verified?
    kyc&.approved?
  end

  def kyc_pending?
    kyc&.pending?
  end

  def kyc_rejected?
    kyc&.rejected?
  end

  def can_create_campaign?
    entrepreneur? && kyc_verified?
  end

  def active_campaigns
    campaigns.where(status: 'active')
  end

  def has_invested_in?(campaign)
    investments.confirmed.exists?(campaign: campaign)
  end

  def total_invested_amount
    investments.confirmed.sum(:amount)
  end

  # Entrepreneur-specific methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def current_revenue_range
    return nil unless entrepreneur?
    "#{current_annual_revenue_min&.to_f&.round(2)} - #{current_annual_revenue_max&.to_f&.round(2)}"
  end

  def projected_revenue_range
    return nil unless entrepreneur?
    "#{projected_annual_revenue_min&.to_f&.round(2)} - #{projected_annual_revenue_max&.to_f&.round(2)}"
  end

  def team_size_range
    return nil unless entrepreneur?
    "#{team_size_min} - #{team_size_max}"
  end

  def years_in_business
    return nil unless entrepreneur? && founded_date
    ((Time.current - founded_date.to_time) / 1.year).floor
  end

  def is_entrepreneur_registration_complete?
    return false unless entrepreneur?
    
    required_fields = [
      :first_name, :last_name, :phone_number, :company_name, :industry, :business_stage,
      :founded_date, :business_description, :problem_being_solved,
      :target_market, :competitive_advantage, :funding_amount_needed,
      :funding_purpose, :current_annual_revenue_min, :current_annual_revenue_max,
      :projected_annual_revenue_min, :projected_annual_revenue_max,
      :team_size_min, :team_size_max, :number_of_co_founders, :tin, :legal_structure
    ]
    
    required_fields.all? { |field| send(field).present? }
  end

  def is_investor_registration_complete?
    return false unless investor?
    
    required_fields = [
      :first_name, :last_name, :phone_number, :company_name, :job_title, :industry,
      :years_of_experience_min, :years_of_experience_max, :typical_investment_amount_min,
      :typical_investment_amount_max, :investment_frequency, :preferred_industries,
      :preferred_investment_stages, :annual_income_min, :annual_income_max,
      :net_worth_min, :net_worth_max, :risk_tolerance, :minimum_investment,
      :maximum_investment, :terms_of_service_accepted, :privacy_policy_accepted
    ]
    
    required_fields.all? { |field| send(field).present? }
  end

  # Investor-specific methods
  def years_of_experience_range
    return nil unless investor?
    "#{years_of_experience_min} - #{years_of_experience_max}"
  end

  def typical_investment_amount_range
    return nil unless investor?
    "$#{typical_investment_amount_min&.to_f&.round(2)} - $#{typical_investment_amount_max&.to_f&.round(2)}"
  end

  def annual_income_range
    return nil unless investor?
    "$#{annual_income_min&.to_f&.round(2)} - $#{annual_income_max&.to_f&.round(2)}"
  end

  def net_worth_range
    return nil unless investor?
    "$#{net_worth_min&.to_f&.round(2)} - $#{net_worth_max&.to_f&.round(2)}"
  end

  def investment_range
    return nil unless investor?
    "$#{minimum_investment&.to_f&.round(2)} - $#{maximum_investment&.to_f&.round(2)}"
  end

  def accept_terms_and_privacy!
    update!(
      terms_of_service_accepted: true,
      privacy_policy_accepted: true,
      terms_accepted_at: Time.current,
      privacy_accepted_at: Time.current
    )
  end

  private

  def founded_date_cannot_be_in_future
    if founded_date.present? && founded_date > Date.current
      errors.add(:founded_date, "cannot be in the future")
    end
  end
end
