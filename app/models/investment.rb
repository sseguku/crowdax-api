class Investment < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  # Enums
  enum :status, {
    pending: 'pending',
    confirmed: 'confirmed',
    cancelled: 'cancelled',
    refunded: 'refunded'
  }

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :campaign_id, message: "has already invested in this campaign" }

  # Callbacks
  before_validation :set_default_status, on: :create
  after_save :update_campaign_current_amount
  after_save :update_campaign_raised_amount
  after_destroy :update_campaign_raised_amount

  # Scopes
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :by_campaign, ->(campaign_id) { where(campaign_id: campaign_id) }
  scope :by_investor, ->(user_id) { where(user_id: user_id) }

  # Instance methods
  def confirmed?
    status == 'confirmed'
  end

  def can_be_confirmed?
    pending? && campaign.approved?
  end

  def can_be_cancelled?
    pending?
  end

  def can_be_refunded?
    confirmed?
  end

  private

  def set_default_status
    self.status ||= 'pending'
  end

  def update_campaign_current_amount
    return unless status_previously_changed? && (confirmed? || status_previously_was == 'confirmed')
    
    campaign.reload
    total_confirmed = campaign.investments.confirmed.sum(:amount)
    campaign.update_column(:current_amount, total_confirmed)
  end

  def update_campaign_raised_amount
    campaign.recalculate_raised_amount!
  end
end
