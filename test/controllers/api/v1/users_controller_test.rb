require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @token = generate_token(@user)
  end

  test "should get profile when authenticated" do
    get api_v1_users_profile_url, 
         headers: { 'Authorization': "Bearer #{@token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @user.email, json_response['data']['email']
  end

  test "should not get profile when not authenticated" do
    get api_v1_users_profile_url
    
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "Authentication required. Please provide a valid token.", 
                 json_response['status']['message']
  end

  test "should get dashboard when authenticated" do
    get api_v1_users_dashboard_url, 
         headers: { 'Authorization': "Bearer #{@token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @user.email, json_response['data']['user']['email']
    assert_includes json_response['data'], 'stats'
  end

  test "should update profile when authenticated" do
    put api_v1_users_profile_url,
        params: {
          user: {
            email: "updated@example.com",
            role: "investor"
          }
        },
        headers: { 'Authorization': "Bearer #{@token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "updated@example.com", json_response['data']['email']
  end

  private

  def generate_token(user)
    # This is a simplified token generation for testing
    # In production, use the actual JWT token from login
    JWT.encode({ sub: user.id, exp: 30.minutes.from_now.to_i }, 
               Rails.application.credentials.secret_key_base, 
               'HS256')
  end
end 