class Breach < ApplicationRecord
  belongs_to :user, optional: true

  # Enums
  enum :breach_type, {
    unauthorized_access: 'unauthorized_access',
    data_exposure: 'data_exposure',
    suspicious_activity: 'suspicious_activity',
    failed_authentication: 'failed_authentication',
    unusual_download: 'unusual_download',
    consent_violation: 'consent_violation',
    encryption_failure: 'encryption_failure'
  }

  enum :severity, {
    low: 'low',
    medium: 'medium',
    high: 'high',
    critical: 'critical'
  }

  enum :status, {
    open: 'open',
    investigating: 'investigating',
    resolved: 'resolved',
    false_positive: 'false_positive'
  }

  # Validations
  validates :breach_type, presence: true, inclusion: { in: breach_types.keys }
  validates :severity, presence: true, inclusion: { in: severities.keys }
  validates :description, presence: true
  validates :detected_at, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }

  # Callbacks
  before_validation :set_defaults, on: :create
  after_create :notify_admins

  # Scopes
  scope :open, -> { where(status: 'open') }
  scope :critical, -> { where(severity: 'critical') }
  scope :recent, -> { where('detected_at >= ?', 24.hours.ago) }
  scope :by_type, ->(type) { where(breach_type: type) }
  scope :by_severity, ->(severity) { where(severity: severity) }

  # Class methods for breach detection
  def self.detect_unauthorized_access(user, ip_address, user_agent, details = {})
    create!(
      user: user,
      breach_type: 'unauthorized_access',
      severity: 'high',
      description: "Unauthorized access attempt detected",
      detected_at: Time.current,
      ip_address: ip_address,
      user_agent: user_agent,
      metadata: details
    )
  end

  def self.detect_suspicious_activity(user, activity_type, details = {})
    create!(
      user: user,
      breach_type: 'suspicious_activity',
      severity: 'medium',
      description: "Suspicious activity detected: #{activity_type}",
      detected_at: Time.current,
      metadata: details
    )
  end

  def self.detect_data_exposure(user, data_type, record_count = nil, details = {})
    create!(
      user: user,
      breach_type: 'data_exposure',
      severity: 'critical',
      description: "Potential data exposure detected: #{data_type}",
      detected_at: Time.current,
      affected_data: data_type,
      affected_records_count: record_count,
      metadata: details
    )
  end

  def self.detect_encryption_failure(component, details = {})
    create!(
      breach_type: 'encryption_failure',
      severity: 'critical',
      description: "Encryption failure detected in #{component}",
      detected_at: Time.current,
      metadata: details
    )
  end

  def self.detect_consent_violation(user, violation_type, details = {})
    create!(
      user: user,
      breach_type: 'consent_violation',
      severity: 'high',
      description: "Consent violation detected: #{violation_type}",
      detected_at: Time.current,
      metadata: details
    )
  end

  # Instance methods
  def resolve!
    update!(status: 'resolved', resolved_at: Time.current)
  end

  def mark_false_positive!
    update!(status: 'false_positive', resolved_at: Time.current)
  end

  def investigating!
    update!(status: 'investigating')
  end

  def duration
    return nil unless resolved_at
    resolved_at - detected_at
  end

  def is_open?
    status == 'open'
  end

  def is_critical?
    severity == 'critical'
  end

  private

  def set_defaults
    self.detected_at ||= Time.current
    self.status ||= 'open'
  end

  def notify_admins
    return unless is_critical? || severity == 'high'
    
    # Send notification to admins
    AdminMailer.breach_notification(self).deliver_later
  end
end
