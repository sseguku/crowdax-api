require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  # Simple test to verify consent endpoints exist and return proper structure
  test "consent endpoints should be accessible" do
    # Test that the routes exist and return proper JSON structure
    # We'll test the actual functionality in model tests instead
    
    # Test consent status endpoint structure
    get "/api/v1/users/consent"
    # Should return unauthorized, but with proper JSON structure
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_includes json_response, 'status'
    assert_includes json_response['status'], 'code'
    assert_includes json_response['status'], 'message'
  end

  test "consent give endpoint should accept POST" do
    post "/api/v1/users/consent", params: { consent_version: 'v1.1' }
    # Should return unauthorized, but with proper JSON structure
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_includes json_response, 'status'
  end

  test "consent withdraw endpoint should accept DELETE" do
    delete "/api/v1/users/consent"
    # Should return unauthorized, but with proper JSON structure
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_includes json_response, 'status'
  end

  # Test User model consent methods directly
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
end 