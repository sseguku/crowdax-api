class TransactionLog < ApplicationRecord
  belongs_to :user, optional: true

  validates :action, presence: true
  validates :record_type, presence: true
  validates :record_id, presence: true
  validates :details, presence: true

  # Scopes for filtering
  scope :recent, -> { where('created_at >= ?', 30.days.ago) }
  scope :by_user, ->(user) { where(user: user) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_record_type, ->(record_type) { where(record_type: record_type) }
  scope :sensitive_actions, -> { where(action: ['data_access', 'data_download', 'data_export', 'kyc_view', 'kyc_download']) }
  scope :admin_actions, -> { where(action: ['admin_login', 'admin_data_access', 'breach_detected']) }

  # Secure logging method
  def self.log!(user:, action:, record:, details: {}, ip_address: nil, user_agent: nil)
    create!(
      user: user,
      action: action,
      record_type: record.class.name,
      record_id: record.id,
      details: details,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  # Enhanced logging methods for specific actions
  def self.log_data_access!(user:, record:, data_type:, ip_address: nil, user_agent: nil)
    log!(
      user: user,
      action: 'data_access',
      record: record,
      details: { data_type: data_type, access_time: Time.current },
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def self.log_data_download!(user:, record:, file_type:, file_size:, ip_address: nil, user_agent: nil)
    log!(
      user: user,
      action: 'data_download',
      record: record,
      details: { file_type: file_type, file_size: file_size, download_time: Time.current },
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def self.log_data_export!(user:, export_type:, record_count:, ip_address: nil, user_agent: nil)
    log!(
      user: user,
      action: 'data_export',
      record: user,
      details: { export_type: export_type, record_count: record_count, export_time: Time.current },
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def self.log_kyc_access!(user:, kyc_record:, access_type:, ip_address: nil, user_agent: nil)
    log!(
      user: user,
      action: 'kyc_access',
      record: kyc_record,
      details: { access_type: access_type, access_time: Time.current },
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def self.log_consent_action!(user:, action:, consent_version: nil, ip_address: nil, user_agent: nil)
    log!(
      user: user,
      action: "consent_#{action}",
      record: user,
      details: { consent_version: consent_version, action_time: Time.current },
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def self.log_breach_detected!(breach:, ip_address: nil, user_agent: nil)
    log!(
      user: breach.user,
      action: 'breach_detected',
      record: breach,
      details: { 
        breach_type: breach.breach_type,
        severity: breach.severity,
        description: breach.description
      },
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def self.log_admin_action!(admin_user:, action:, target_record:, details: {}, ip_address: nil, user_agent: nil)
    log!(
      user: admin_user,
      action: "admin_#{action}",
      record: target_record,
      details: details.merge(admin_action_time: Time.current),
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  # Instance methods
  def is_sensitive?
    sensitive_actions.include?(action)
  end

  def is_admin_action?
    action.start_with?('admin_')
  end

  def formatted_details
    details.merge(
      timestamp: created_at.iso8601,
      user_email: user&.email,
      user_role: user&.role
    )
  end

  def risk_level
    case action
    when 'data_download', 'data_export', 'kyc_download'
      'high'
    when 'data_access', 'kyc_access'
      'medium'
    else
      'low'
    end
  end
end
