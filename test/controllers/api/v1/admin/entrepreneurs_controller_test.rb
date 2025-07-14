require "test_helper"

class Api::V1::Admin::EntrepreneursControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @admin = users(:one)
    @admin.update!(role: :admin)
    
    @entrepreneur = users(:two)
    @entrepreneur.update!(role: :entrepreneur)
    
    # Create KYC with status that doesn't require documents, skip validation
    @kyc = Kyc.new(
      user: @entrepreneur,
      id_number: "123456789",
      phone: "+1234567890",
      address: "123 Test St",
      status: 'under_review'
    )
    @kyc.save(validate: false)
    @kyc.documents.attach(
      io: StringIO.new("test document content"),
      filename: "document1.pdf",
      content_type: "application/pdf"
    )
    @kyc.reload
    @kyc.status = 'pending'
    @kyc.save!
  end

  test "should require admin authentication" do
    get "/api/v1/admin/entrepreneurs"
    assert_response :unauthorized
  end

  test "should deny access to non-admin users" do
    sign_in @entrepreneur
    get "/api/v1/admin/entrepreneurs"
    assert_response :forbidden
  end

  test "should list entrepreneurs" do
    sign_in @admin
    get "/api/v1/admin/entrepreneurs"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Entrepreneurs retrieved successfully.", json_response["status"]["message"]
    assert_includes json_response["data"], "id"
  end

  test "should filter entrepreneurs by KYC status" do
    sign_in @admin
    get "/api/v1/admin/entrepreneurs?status=kyc_pending"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["data"].length > 0
  end

  test "should show entrepreneur details" do
    sign_in @admin
    get "/api/v1/admin/entrepreneurs/#{@entrepreneur.id}"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @entrepreneur.id, json_response["data"]["id"]
    assert_equal "pending", json_response["data"]["kyc_status"]
  end

  test "should approve entrepreneur KYC" do
    sign_in @admin
    post "/api/v1/admin/entrepreneurs/#{@entrepreneur.id}/approve"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Entrepreneur approved successfully.", json_response["status"]["message"]
    
    @entrepreneur.reload
    assert @entrepreneur.kyc_verified?
  end

  test "should reject entrepreneur KYC" do
    sign_in @admin
    post "/api/v1/admin/entrepreneurs/#{@entrepreneur.id}/reject"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Entrepreneur rejected successfully.", json_response["status"]["message"]
    
    @entrepreneur.reload
    assert @entrepreneur.kyc.rejected?
  end

  test "should deactivate entrepreneur" do
    sign_in @admin
    post "/api/v1/admin/entrepreneurs/#{@entrepreneur.id}/deactivate"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Entrepreneur deactivated successfully.", json_response["status"]["message"]
    
    @entrepreneur.reload
    assert_equal "visitor", @entrepreneur.role
  end

  test "should not approve already approved entrepreneur" do
    @kyc.update!(status: 'approved')
    sign_in @admin
    post "/api/v1/admin/entrepreneurs/#{@entrepreneur.id}/approve"
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "Entrepreneur is already approved.", json_response["status"]["message"]
  end

  test "should not reject already rejected entrepreneur" do
    @kyc.update!(status: 'rejected')
    sign_in @admin
    post "/api/v1/admin/entrepreneurs/#{@entrepreneur.id}/reject"
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "Entrepreneur is already rejected.", json_response["status"]["message"]
  end

  test "should not approve entrepreneur without KYC" do
    @kyc.destroy
    sign_in @admin
    post "/api/v1/admin/entrepreneurs/#{@entrepreneur.id}/approve"
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "Cannot approve entrepreneur without KYC.", json_response["status"]["message"]
  end

  test "should return 404 for non-existent entrepreneur" do
    sign_in @admin
    get "/api/v1/admin/entrepreneurs/999999"
    
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Entrepreneur not found.", json_response["status"]["message"]
  end
end 