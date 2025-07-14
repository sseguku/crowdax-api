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
end
