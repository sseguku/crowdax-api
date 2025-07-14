require "test_helper"

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update!(password: 'password123', password_confirmation: 'password123')
  end

  test "should login with valid credentials" do
    post users_sign_in_url, params: {
      user: {
        email: @user.email,
        password: 'password123'
      }
    }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Logged in successfully.", json_response['status']['message']
    assert_includes json_response['data'], 'token'
    assert_includes json_response['data'], 'user'
  end

  test "should not login with invalid credentials" do
    post users_sign_in_url, params: {
      user: {
        email: @user.email,
        password: 'wrongpassword'
      }
    }
    
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "Invalid email or password.", json_response['status']['message']
  end

  test "should get current user with valid token" do
    token = generate_token(@user)
    
    get users_current_user_url, 
         headers: { 'Authorization': "Bearer #{token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "User authenticated.", json_response['status']['message']
    assert_equal @user.email, json_response['data']['email']
  end

  test "should not get current user without token" do
    get users_current_user_url
    
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "No active session found.", json_response['status']['message']
  end

  test "should logout successfully" do
    token = generate_token(@user)
    
    delete users_sign_out_url, 
           headers: { 'Authorization': "Bearer #{token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Logged out successfully.", json_response['status']['message']
  end

  test "should refresh token" do
    token = generate_token(@user)
    
    post users_refresh_token_url, 
         headers: { 'Authorization': "Bearer #{token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Token refreshed successfully.", json_response['status']['message']
    assert_includes json_response['data'], 'token'
  end

  private

  def generate_token(user)
    JWT.encode({ sub: user.id, exp: 30.minutes.from_now.to_i }, 
               Rails.application.credentials.secret_key_base, 
               'HS256')
  end
end 