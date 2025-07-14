class BreachDetectionService
  def initialize(request = nil, current_user = nil)
    @request = request
    @current_user = current_user
  end

  # Detect unauthorized access attempts
  def detect_unauthorized_access
    return unless @request && @current_user.nil?
    
    # Check for suspicious patterns
    if suspicious_ip? || suspicious_user_agent? || too_many_requests?
      Breach.detect_unauthorized_access(
        nil,
        @request.remote_ip,
        @request.user_agent,
        {
          path: @request.path,
          method: @request.method,
          referer: @request.referer
        }
      )
    end
  end

  # Detect suspicious data access patterns
  def detect_suspicious_data_access(data_type, record_count = nil)
    return unless @current_user
    
    # Check for unusual access patterns
    if unusual_access_pattern?(data_type) || bulk_data_access?(record_count)
      Breach.detect_data_exposure(
        @current_user,
        data_type,
        record_count,
        {
          path: @request&.path,
          method: @request&.method,
          ip_address: @request&.remote_ip
        }
      )
    end
  end

  # Detect consent violations
  def detect_consent_violation(violation_type)
    return unless @current_user
    
    Breach.detect_consent_violation(
      @current_user,
      violation_type,
      {
        path: @request&.path,
        method: @request&.method,
        ip_address: @request&.remote_ip
      }
    )
  end

  # Detect encryption failures
  def detect_encryption_failure(component, error_details = {})
    Breach.detect_encryption_failure(
      component,
      {
        error: error_details[:error],
        stack_trace: error_details[:stack_trace],
        timestamp: Time.current
      }
    )
  end

  # Detect unusual download patterns
  def detect_unusual_download(file_type, file_count = 1)
    return unless @current_user
    
    if bulk_download?(file_count) || unusual_file_type?(file_type)
      Breach.detect_suspicious_activity(
        @current_user,
        "unusual_download",
        {
          file_type: file_type,
          file_count: file_count,
          path: @request&.path,
          ip_address: @request&.remote_ip
        }
      )
    end
  end

  # Detect failed authentication attempts
  def detect_failed_authentication(email, reason = nil)
    Breach.detect_suspicious_activity(
      nil,
      "failed_authentication",
      {
        email: email,
        reason: reason,
        ip_address: @request&.remote_ip,
        user_agent: @request&.user_agent
      }
    )
  end

  private

  def suspicious_ip?
    # Check against known malicious IP ranges
    # This is a simplified check - in production, use a proper IP reputation service
    suspicious_ranges = [
      '192.168.1.0/24',  # Example: internal network access from external
      '10.0.0.0/8'       # Example: private network
    ]
    
    suspicious_ranges.any? do |range|
      IPAddr.new(range).include?(@request.remote_ip)
    end
  end

  def suspicious_user_agent?
    # Check for suspicious user agents
    suspicious_patterns = [
      /bot/i,
      /crawler/i,
      /scraper/i,
      /curl/i,
      /wget/i
    ]
    
    suspicious_patterns.any? { |pattern| pattern.match?(@request.user_agent) }
  end

  def too_many_requests?
    # Check rate limiting (simplified)
    # In production, use Redis or similar for proper rate limiting
    Rails.cache.read("rate_limit:#{@request.remote_ip}").to_i > 100
  end

  def unusual_access_pattern?(data_type)
    # Check for unusual access patterns
    # This is a simplified check - in production, use ML or behavioral analysis
    case data_type
    when 'kyc_documents'
      # Check if user is accessing KYC docs outside normal hours
      current_hour = Time.current.hour
      current_hour < 6 || current_hour > 22
    when 'personal_data'
      # Check for bulk data access
      true # Simplified for demo
    else
      false
    end
  end

  def bulk_data_access?(record_count)
    record_count && record_count > 100
  end

  def bulk_download?(file_count)
    file_count > 10
  end

  def unusual_file_type?(file_type)
    # Check for unusual file types being downloaded
    unusual_types = ['exe', 'bat', 'sh', 'ps1']
    unusual_types.include?(file_type.downcase)
  end
end 