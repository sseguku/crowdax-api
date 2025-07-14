require "test_helper"

class BreachTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "should create breach with valid attributes" do
    breach = Breach.new(
      user: @user,
      breach_type: 'suspicious_activity',
      severity: 'medium',
      description: 'Test breach',
      detected_at: Time.current
    )
    
    assert breach.save
  end

  test "should not create breach without required attributes" do
    breach = Breach.new
    assert_not breach.save
    assert_includes breach.errors[:breach_type], "can't be blank"
    assert_includes breach.errors[:severity], "can't be blank"
    assert_includes breach.errors[:description], "can't be blank"
  end

  test "should detect unauthorized access" do
    breach = Breach.detect_unauthorized_access(
      @user,
      '192.168.1.100',
      'Mozilla/5.0',
      { path: '/api/v1/users/profile' }
    )
    
    assert breach.persisted?
    assert_equal 'unauthorized_access', breach.breach_type
    assert_equal 'high', breach.severity
    assert_equal '192.168.1.100', breach.ip_address
  end

  test "should detect suspicious activity" do
    breach = Breach.detect_suspicious_activity(
      @user,
      'bulk_data_download',
      { file_count: 150 }
    )
    
    assert breach.persisted?
    assert_equal 'suspicious_activity', breach.breach_type
    assert_equal 'medium', breach.severity
  end

  test "should detect data exposure" do
    breach = Breach.detect_data_exposure(
      @user,
      'kyc_documents',
      500,
      { access_time: '02:30' }
    )
    
    assert breach.persisted?
    assert_equal 'data_exposure', breach.breach_type
    assert_equal 'critical', breach.severity
    assert_equal 'kyc_documents', breach.affected_data
    assert_equal 500, breach.affected_records_count
  end

  test "should detect encryption failure" do
    breach = Breach.detect_encryption_failure(
      'kyc_document_encryption',
      { error: 'Decryption failed', component: 'KYC' }
    )
    
    assert breach.persisted?
    assert_equal 'encryption_failure', breach.breach_type
    assert_equal 'critical', breach.severity
    assert_nil breach.user
  end

  test "should detect consent violation" do
    breach = Breach.detect_consent_violation(
      @user,
      'processing_without_consent',
      { data_type: 'personal_information' }
    )
    
    assert breach.persisted?
    assert_equal 'consent_violation', breach.breach_type
    assert_equal 'high', breach.severity
  end

  test "should resolve breach" do
    breach = Breach.create!(
      user: @user,
      breach_type: 'suspicious_activity',
      severity: 'medium',
      description: 'Test breach',
      detected_at: Time.current
    )
    
    assert breach.is_open?
    breach.resolve!
    assert_equal 'resolved', breach.status
    assert_not_nil breach.resolved_at
  end

  test "should mark breach as false positive" do
    breach = Breach.create!(
      user: @user,
      breach_type: 'suspicious_activity',
      severity: 'medium',
      description: 'Test breach',
      detected_at: Time.current
    )
    
    breach.mark_false_positive!
    assert_equal 'false_positive', breach.status
    assert_not_nil breach.resolved_at
  end

  test "should calculate duration correctly" do
    breach = Breach.create!(
      user: @user,
      breach_type: 'suspicious_activity',
      severity: 'medium',
      description: 'Test breach',
      detected_at: 1.hour.ago
    )
    
    assert_nil breach.duration
    
    breach.resolve!
    assert_in_delta 3600, breach.duration, 10 # Within 10 seconds
  end

  test "should scope breaches correctly" do
    # Create breaches with different statuses
    open_breach = Breach.create!(
      user: @user,
      breach_type: 'suspicious_activity',
      severity: 'medium',
      description: 'Open breach',
      detected_at: Time.current
    )
    
    resolved_breach = Breach.create!(
      user: @user,
      breach_type: 'data_exposure',
      severity: 'critical',
      description: 'Resolved breach',
      detected_at: 2.hours.ago
    )
    resolved_breach.resolve!
    
    assert_includes Breach.open, open_breach
    assert_not_includes Breach.open, resolved_breach
    
    assert_includes Breach.critical, resolved_breach
    assert_not_includes Breach.critical, open_breach
  end

  test "should check severity correctly" do
    critical_breach = Breach.create!(
      user: @user,
      breach_type: 'data_exposure',
      severity: 'critical',
      description: 'Critical breach',
      detected_at: Time.current
    )
    
    medium_breach = Breach.create!(
      user: @user,
      breach_type: 'suspicious_activity',
      severity: 'medium',
      description: 'Medium breach',
      detected_at: Time.current
    )
    
    assert critical_breach.is_critical?
    assert_not medium_breach.is_critical?
  end
end
