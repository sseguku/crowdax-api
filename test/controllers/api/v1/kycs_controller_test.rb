require "test_helper"

class Api::V1::KycsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @admin = users(:admin)
    @kyc = kycs(:one)
    @kyc.update!(user: @user)
  end

  test "should get index when authenticated" do
    sign_in @user
    get api_v1_kycs_url, headers: { 'Authorization': "Bearer #{generate_jwt_token(@user)}" }
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 200, json_response['status']['code']
  end

  test "should get index when not authenticated" do
    get api_v1_kycs_url
    assert_response :unauthorized
  end

  test "should show kyc when owner" do
    sign_in @user
    get api_v1_kyc_url(@kyc), headers: { 'Authorization': "Bearer #{generate_jwt_token(@user)}" }
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @kyc.id_number, json_response['data']['id_number']
  end

  test "should not show kyc when not owner" do
    other_user = users(:two)
    sign_in other_user
    get api_v1_kyc_url(@kyc), headers: { 'Authorization': "Bearer #{generate_jwt_token(other_user)}" }
    assert_response :not_found
  end

  test "should create kyc with valid params" do
    sign_in @user
    @user.kyc.destroy if @user.kyc.present?
    
    kyc_params = {
      kyc: {
        id_number: "TEST123456",
        phone: "+1234567890",
        address: "123 Test St, City, Country",
        status: "pending",
        docs_metadata: { "passport" => "test_passport", "utility_bill" => "test_bill" }.to_json
      }
    }

    assert_difference('Kyc.count') do
      post api_v1_kycs_url, params: kyc_params, headers: { 'Authorization': "Bearer #{generate_jwt_token(@user)}" }
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "TEST123456", json_response['data']['id_number']
  end

  test "should not create kyc if user already has one" do
    sign_in @user
    
    kyc_params = {
      kyc: {
        id_number: "TEST123456",
        phone: "+1234567890",
        address: "123 Test St, City, Country"
      }
    }

    assert_no_difference('Kyc.count') do
      post api_v1_kycs_url, params: kyc_params, headers: { 'Authorization': "Bearer #{generate_jwt_token(@user)}" }
    end

    assert_response :unprocessable_entity
  end

  test "should update kyc when owner" do
    sign_in @user
    patch api_v1_kyc_url(@kyc), params: {
      kyc: { phone: "+1987654321" }
    }, headers: { 'Authorization': "Bearer #{generate_jwt_token(@user)}" }
    
    assert_response :success
    @kyc.reload
    assert_equal "+1987654321", @kyc.phone
  end

  test "should not update kyc when not owner" do
    other_user = users(:two)
    sign_in other_user
    patch api_v1_kyc_url(@kyc), params: {
      kyc: { phone: "+1987654321" }
    }, headers: { 'Authorization': "Bearer #{generate_jwt_token(other_user)}" }
    
    assert_response :not_found
  end

  test "should destroy kyc when owner" do
    sign_in @user
    assert_difference('Kyc.count', -1) do
      delete api_v1_kyc_url(@kyc), headers: { 'Authorization': "Bearer #{generate_jwt_token(@user)}" }
    end
    assert_response :success
  end

  test "should approve kyc when admin" do
    sign_in @admin
    @kyc.update!(status: 'pending')
    
    assert_enqueued_with(job: KycApprovalJob) do
      post approve_api_v1_kyc_url(@kyc), headers: { 'Authorization': "Bearer #{generate_jwt_token(@admin)}" }
    end
    
    assert_response :accepted
    json_response = JSON.parse(response.body)
    assert_equal 202, json_response['status']['code']
  end

  test "should not approve kyc when not admin" do
    sign_in @user
    post approve_api_v1_kyc_url(@kyc), headers: { 'Authorization': "Bearer #{generate_jwt_token(@user)}" }
    assert_response :forbidden
  end

  test "should not approve kyc when not pending" do
    sign_in @admin
    @kyc.update!(status: 'approved')
    
    post approve_api_v1_kyc_url(@kyc), headers: { 'Authorization': "Bearer #{generate_jwt_token(@admin)}" }
    assert_response :unprocessable_entity
  end

  private

  def generate_jwt_token(user)
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  end
end
