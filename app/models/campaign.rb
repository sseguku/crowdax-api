class Campaign < ApplicationRecord
  belongs_to :user

  # ActiveStorage for pitch deck
  has_one_attached :pitch_deck

  # Associations
  has_many :investments, dependent: :destroy
  has_many :investors, through: :investments, source: :user

  # Enums
  enum :campaign_status, {
    draft: 'draft',
    submitted: 'submitted',
    approved: 'approved',
    rejected: 'rejected',
    funded: 'funded',
    closed: 'closed'
  }

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :sector, presence: true, inclusion: { 
    in: %w[technology healthcare finance education retail manufacturing energy real_estate other],
    message: "must be a valid sector" 
  }
  validates :goal_amount, presence: true, numericality: { greater_than: 0 }
  validates :current_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :team, presence: true, length: { minimum: 10 }
  validates :campaign_status, presence: true, inclusion: { in: campaign_statuses.keys }
  validates :pitch_deck, presence: true
  validate :acceptable_pitch_deck

  # Callbacks
  before_validation :set_default_campaign_status, on: :create
  before_validation :set_default_current_amount, on: :create

  # Scopes
  scope :submitted, -> { where(campaign_status: 'submitted') }
  scope :approved, -> { where(campaign_status: 'approved') }
  scope :funded, -> { where(campaign_status: 'funded') }
  scope :closed, -> { where(campaign_status: 'closed') }
  scope :by_sector, ->(sector) { where(sector: sector) }
  scope :running_campaigns, -> { where(campaign_status: ['approved', 'funded']) }
  scope :top_funded, ->(limit = 10) { 
    where(campaign_status: 'funded')
    .order('current_amount DESC')
    .limit(limit) 
  }
  scope :recent, ->(limit = 10) { order(created_at: :desc).limit(limit) }
  scope :with_goal_above, ->(amount) { where('goal_amount > ?', amount) }
  scope :with_goal_below, ->(amount) { where('goal_amount < ?', amount) }
  scope :nearly_funded, -> { where('current_amount >= 0.8 * goal_amount AND current_amount < goal_amount') }
  scope :fully_funded, -> { where('current_amount >= goal_amount') }
  scope :active, -> { where(campaign_status: ['approved', 'funded']) }

  # Instance methods
  def funding_progress
    return 0 if goal_amount.zero?
    ((current_amount || 0) / goal_amount * 100).round(2)
  end

  def can_be_activated?
    approved? && pitch_deck.attached?
  end

  def can_be_funded?
    approved? && funding_progress >= 100
  end

  def has_confirmed_investor?(user)
    investments.confirmed.exists?(user: user)
  end

  def total_investors_count
    investments.confirmed.count
  end

  def total_invested_amount
    investments.confirmed.sum(:amount)
  end

  def recalculate_raised_amount!
    update_column(:raised_amount, investments.confirmed.sum(:amount))
  end

  private

  def set_default_campaign_status
    self.campaign_status ||= 'draft'
  end

  def set_default_current_amount
    self.current_amount ||= 0
  end

  def acceptable_pitch_deck
    return unless pitch_deck.attached?

    unless pitch_deck.content_type.in?(%w[application/pdf application/vnd.openxmlformats-officedocument.presentationml.presentation])
      errors.add(:pitch_deck, 'must be a PDF or PowerPoint file')
    end
  end
end
