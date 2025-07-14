class AuditLoggingService
  def initialize(request = nil, current_user = nil)
    @request = request
    @current_user = current_user
  end

  # Log data access
  def log_data_access(record, data_type)
    return unless @current_user
    
    TransactionLog.log_data_access!(
      user: @current_user,
      record: record,
      data_type: data_type,
      ip_address: @request&.remote_ip,
      user_agent: @request&.user_agent
    )
  end

  # Log data download
  def log_data_download(record, file_type, file_size)
    return unless @current_user
    
    TransactionLog.log_data_download!(
      user: @current_user,
      record: record,
      file_type: file_type,
      file_size: file_size,
      ip_address: @request&.remote_ip,
      user_agent: @request&.user_agent
    )
  end

  # Log data export
  def log_data_export(export_type, record_count)
    return unless @current_user
    
    TransactionLog.log_data_export!(
      user: @current_user,
      export_type: export_type,
      record_count: record_count,
      ip_address: @request&.remote_ip,
      user_agent: @request&.user_agent
    )
  end

  # Log KYC access
  def log_kyc_access(kyc_record, access_type)
    return unless @current_user
    
    TransactionLog.log_kyc_access!(
      user: @current_user,
      kyc_record: kyc_record,
      access_type: access_type,
      ip_address: @request&.remote_ip,
      user_agent: @request&.user_agent
    )
  end

  # Log consent actions
  def log_consent_action(action, consent_version = nil)
    return unless @current_user
    
    TransactionLog.log_consent_action!(
      user: @current_user,
      action: action,
      consent_version: consent_version,
      ip_address: @request&.remote_ip,
      user_agent: @request&.user_agent
    )
  end

  # Log admin actions
  def log_admin_action(action, target_record, details = {})
    return unless @current_user&.admin?
    
    TransactionLog.log_admin_action!(
      admin_user: @current_user,
      action: action,
      target_record: target_record,
      details: details,
      ip_address: @request&.remote_ip,
      user_agent: @request&.user_agent
    )
  end

  # Log breach detection
  def log_breach_detected(breach)
    TransactionLog.log_breach_detected!(
      breach: breach,
      ip_address: @request&.remote_ip,
      user_agent: @request&.user_agent
    )
  end

  # Log user profile updates
  def log_profile_update(updated_fields)
    return unless @current_user
    
    TransactionLog.log!(
      user: @current_user,
      action: 'profile_updated',
      record: @current_user,
      details: { updated_fields: updated_fields, update_time: Time.current },
      ip_address: @request&.remote_ip,
      user_agent: @request&.user_agent
    )
  end

  # Log login attempts
  def log_login_attempt(email, success, reason = nil)
    # Find existing user or create a temporary one for logging
    existing_user = User.find_by(email: email)
    temp_user = existing_user || User.new(email: email)
    
    TransactionLog.log!(
      user: nil,
      action: success ? 'login_success' : 'login_failed',
      record: temp_user,
      details: { 
        email: email,
        success: success,
        reason: reason,
        attempt_time: Time.current
      },
      ip_address: @request&.remote_ip,
      user_agent: @request&.user_agent
    )
  end

  # Log password changes
  def log_password_change
    return unless @current_user
    
    TransactionLog.log!(
      user: @current_user,
      action: 'password_changed',
      record: @current_user,
      details: { change_time: Time.current },
      ip_address: @request&.remote_ip,
      user_agent: @request&.user_agent
    )
  end

  # Log data deletion requests
  def log_deletion_request(deletion_request)
    TransactionLog.log!(
      user: @current_user,
      action: 'deletion_requested',
      record: deletion_request,
      details: { 
        reason: deletion_request.reason,
        request_time: Time.current
      },
      ip_address: @request&.remote_ip,
      user_agent: @request&.user_agent
    )
  end

  # Generate audit report
  def self.generate_audit_report(start_date: 30.days.ago, end_date: Time.current, user: nil)
    logs = TransactionLog.where(created_at: start_date..end_date)
    logs = logs.by_user(user) if user
    
    {
      total_logs: logs.count,
      sensitive_actions: logs.sensitive_actions.count,
      admin_actions: logs.admin_actions.count,
      by_action: logs.group(:action).count,
      by_user: logs.joins(:user).group('users.email').count,
      by_date: logs.group(:created_at).count,
      risk_analysis: {
        high_risk: logs.where(action: ['data_download', 'data_export', 'kyc_download']).count,
        medium_risk: logs.where(action: ['data_access', 'kyc_access']).count,
        low_risk: logs.where.not(action: ['data_download', 'data_export', 'kyc_download', 'data_access', 'kyc_access']).count
      }
    }
  end

  # Check for suspicious activity
  def self.detect_suspicious_activity(user, time_window: 1.hour)
    recent_logs = TransactionLog.by_user(user).where('created_at >= ?', time_window.ago)
    
    suspicious_patterns = []
    
    # Check for unusual number of data downloads
    if recent_logs.where(action: 'data_download').count > 10
      suspicious_patterns << 'excessive_data_downloads'
    end
    
    # Check for unusual access times (between 6 AM and 10 PM)
    unusual_hours = recent_logs.select do |log|
      hour = log.created_at.hour
      hour < 6 || hour > 22
    end
    
    if unusual_hours.count > 5
      suspicious_patterns << 'unusual_access_times'
    end
    
    # Check for rapid successive actions
    if recent_logs.where('created_at >= ?', 5.minutes.ago).count > 20
      suspicious_patterns << 'rapid_successive_actions'
    end
    
    suspicious_patterns
  end
end 