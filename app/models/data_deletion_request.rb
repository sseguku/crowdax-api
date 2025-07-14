class DataDeletionRequest < ApplicationRecord
  belongs_to :user

  # Enums
  enum :status, {
    pending: 'pending',
    under_review: 'under_review',
    approved: 'approved',
    rejected: 'rejected',
    completed: 'completed',
    on_hold: 'on_hold'
  }

  # Validations
  validates :requested_at, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :reason, presence: true, length: { minimum: 10 }

  # Callbacks
  before_validation :set_defaults, on: :create
  after_create :log_deletion_request

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :under_review, -> { where(status: 'under_review') }
  scope :completed, -> { where(status: 'completed') }
  scope :recent, -> { where('requested_at >= ?', 30.days.ago) }
  scope :regulatory_hold, -> { where(regulatory_hold: true) }

  # Instance methods
  def approve!(admin_user, notes = nil)
    update!(
      status: 'approved',
      processed_at: Time.current,
      processed_by: admin_user.email,
      admin_notes: notes
    )
  end

  def reject!(admin_user, reason)
    update!(
      status: 'rejected',
      processed_at: Time.current,
      processed_by: admin_user.email,
      admin_notes: reason
    )
  end

  def complete!
    update!(
      status: 'completed',
      processed_at: Time.current
    )
  end

  def put_on_hold!(reason)
    update!(
      status: 'on_hold',
      hold_reason: reason,
      regulatory_hold: true
    )
  end

  def days_since_request
    ((Time.current - requested_at) / 1.day).round
  end

  def is_overdue?
    days_since_request > 30
  end

  def can_be_processed?
    !regulatory_hold && status.in?(['pending', 'under_review'])
  end

  private

  def set_defaults
    self.requested_at ||= Time.current
    self.status ||= 'pending'
    self.estimated_completion_date ||= 30.days.from_now
  end

  def log_deletion_request
    TransactionLog.create!(
      user: user,
      action: 'data_deletion_requested',
      record_type: 'DataDeletionRequest',
      record_id: id,
      details: {
        reason: reason,
        status: status,
        data_types: data_types_requested
      },
      ip_address: 'system'
    )
  end
end
