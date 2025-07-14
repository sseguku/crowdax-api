require "test_helper"

class Api::V1::Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @admin = users(:one)
    @admin.update!(role: :admin)
    
    @entrepreneur = users(:two)
    @entrepreneur.update!(role: :entrepreneur)
    
    @investor = users(:three)
    @investor.update!(role: :investor)
    
    # Create KYC for entrepreneur
    @kyc = Kyc.create!(
      user: @entrepreneur,
      id_number: "123456789",
      phone: "+1234567890",
      address: "123 Test St",
      status: 'pending'
    )
    
    # Create campaign
    @campaign = Campaign.create!(
      user: @entrepreneur,
      title: "Test Campaign",
      sector: "technology",
      goal_amount: 10000.00,
      team: "Test team for campaign",
      campaign_status: "submitted"
    )
    
    @campaign.pitch_deck.attach(
      io: StringIO.new("test pitch deck content"),
      filename: "pitch_deck.pdf",
      content_type: "application/pdf"
    )
    
    # Create investment
    @investment = Investment.create!(
      user: @investor,
      campaign: @campaign,
      amount: 1000.00,
      status: 'confirmed'
    )
  end

  test "should require admin authentication" do
    get "/api/v1/admin/dashboard"
    assert_response :unauthorized
  end

  test "should deny access to non-admin users" do
    sign_in @entrepreneur
    get "/api/v1/admin/dashboard"
    assert_response :forbidden
  end

  test "should return dashboard metrics" do
    sign_in @admin
    get "/api/v1/admin/dashboard"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Dashboard metrics retrieved successfully.", json_response["status"]["message"]
    
    data = json_response["data"]
    assert_includes data, "overview"
    assert_includes data, "campaigns"
    assert_includes data, "users"
    assert_includes data, "investments"
    assert_includes data, "top_performers"
    assert_includes data, "recent_activity"
  end

  test "should include overview metrics" do
    sign_in @admin
    get "/api/v1/admin/dashboard"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    overview = json_response["data"]["overview"]
    
    assert_includes overview, "total_campaigns"
    assert_includes overview, "total_users"
    assert_includes overview, "total_investments"
    assert_includes overview, "total_funding_raised"
    assert_includes overview, "active_campaigns"
    assert_includes overview, "pending_approvals"
  end

  test "should include campaign metrics" do
    sign_in @admin
    get "/api/v1/admin/dashboard"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    campaigns = json_response["data"]["campaigns"]
    
    assert_includes campaigns, "by_status"
    assert_includes campaigns, "by_sector"
    assert_includes campaigns, "funding_progress"
    assert_includes campaigns, "recent_campaigns"
  end

  test "should include user metrics" do
    sign_in @admin
    get "/api/v1/admin/dashboard"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    users = json_response["data"]["users"]
    
    assert_includes users, "by_role"
    assert_includes users, "entrepreneurs"
    assert_includes users, "investors"
    assert_includes users, "recent_signups"
  end

  test "should include investment metrics" do
    sign_in @admin
    get "/api/v1/admin/dashboard"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    investments = json_response["data"]["investments"]
    
    assert_includes investments, "total_amount"
    assert_includes investments, "average_investment"
    assert_includes investments, "by_status"
    assert_includes investments, "recent_investments"
  end

  test "should include top performers metrics" do
    sign_in @admin
    get "/api/v1/admin/dashboard"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    top_performers = json_response["data"]["top_performers"]
    
    assert_includes top_performers, "top_campaigns"
    assert_includes top_performers, "top_investors"
    assert_includes top_performers, "top_entrepreneurs"
  end

  test "should include recent activity metrics" do
    sign_in @admin
    get "/api/v1/admin/dashboard"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    recent_activity = json_response["data"]["recent_activity"]
    
    assert_includes recent_activity, "recent_campaigns"
    assert_includes recent_activity, "recent_investments"
    assert_includes recent_activity, "recent_kyc_submissions"
  end

  test "should calculate correct overview metrics" do
    sign_in @admin
    get "/api/v1/admin/dashboard"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    overview = json_response["data"]["overview"]
    
    assert_equal 1, overview["total_campaigns"]
    assert_equal 3, overview["total_users"] # 3 users in fixtures
    assert_equal 1, overview["total_investments"]
    assert_equal 1000.0, overview["total_funding_raised"]
    assert_equal 0, overview["active_campaigns"] # campaign is submitted, not active
  end

  test "should calculate correct pending approvals" do
    sign_in @admin
    get "/api/v1/admin/dashboard"
    
    assert_response :success
    json_response = JSON.parse(response.body)
    pending_approvals = json_response["data"]["overview"]["pending_approvals"]
    
    assert_equal 1, pending_approvals["campaigns"] # submitted campaign
    assert_equal 1, pending_approvals["entrepreneurs"] # entrepreneur with pending KYC
    assert_equal 1, pending_approvals["kycs"] # pending KYC
  end
end 