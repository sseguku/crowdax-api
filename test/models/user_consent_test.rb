require "test_helper"

class UserConsentTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "user should be able to give consent" do
    assert_not @user.consent_given?
    @user.give_consent!('v1.1')
    assert @user.consent_given?
    assert_equal 'v1.1', @user.consent_version
  end

  test "user should be able to withdraw consent" do
    @user.give_consent!('v1.1')
    assert @user.consent_given?
    @user.withdraw_consent!
    assert_not @user.consent_given?
    assert_not_nil @user.consent_withdrawn_at
  end

  test "consent_given? should work correctly" do
    # Initially no consent
    assert_not @user.consent_given?
    
    # Give consent
    @user.give_consent!
    assert @user.consent_given?
    
    # Withdraw consent
    @user.withdraw_consent!
    assert_not @user.consent_given?
    
    # Give consent again (should override withdrawal)
    @user.give_consent!
    assert @user.consent_given?
  end

  test "consent should track version" do
    @user.give_consent!('v2.0')
    assert_equal 'v2.0', @user.consent_version
    
    @user.give_consent!('v3.0')
    assert_equal 'v3.0', @user.consent_version
  end

  test "consent timestamps should be set correctly" do
    assert_nil @user.consent_given_at
    assert_nil @user.consent_withdrawn_at
    
    @user.give_consent!
    assert_not_nil @user.consent_given_at
    assert_nil @user.consent_withdrawn_at
    
    @user.withdraw_consent!
    assert_not_nil @user.consent_given_at
    assert_not_nil @user.consent_withdrawn_at
  end

  test "consent_given? should handle edge cases" do
    # User with consent_given_at but no consent_withdrawn_at
    @user.update!(consent_given_at: Time.current, consent_withdrawn_at: nil)
    assert @user.consent_given?
    
    # User with consent_withdrawn_at after consent_given_at
    @user.update!(consent_given_at: 1.hour.ago, consent_withdrawn_at: Time.current)
    assert_not @user.consent_given?
    
    # User with consent_given_at after consent_withdrawn_at (re-consent)
    @user.update!(consent_given_at: Time.current, consent_withdrawn_at: 1.hour.ago)
    assert @user.consent_given?
  end
end 