require "test_helper"

class Api::V1::CampaignsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @admin = users(:admin)
    @campaign = campaigns(:one)
    sign_in @user
  end

  test "should get index" do
    get api_v1_campaigns_url, as: :json
    assert_response :success
    assert_includes response.parsed_body["status"]["message"], "retrieved"
  end

  test "should show campaign" do
    get api_v1_campaign_url(@campaign), as: :json
    assert_response :success
    assert_equal @campaign.title, response.parsed_body["data"]["title"]
  end

  test "should create campaign with valid data and file" do
    file = fixture_file_upload("files/sample.pdf", "application/pdf")
    assert_difference('Campaign.count') do
      post api_v1_campaigns_url, params: {
        campaign: {
          title: "New Campaign",
          sector: "technology",
          goal_amount: 10000,
          team: "A great team for a great campaign!",
          campaign_status: "draft",
          pitch_deck: file
        }
      }, headers: { 'Accept' => 'application/json' }
    end
    assert_response :created
    assert_equal "New Campaign", response.parsed_body["data"]["title"]
  end

  test "should not create campaign with invalid data" do
    assert_no_difference('Campaign.count') do
      post api_v1_campaigns_url, params: {
        campaign: {
          title: "",
          sector: "invalid",
          goal_amount: -1,
          team: "short",
          campaign_status: "invalid"
        }
      }, as: :json
    end
    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"].join, "can't be blank"
  end

  test "should update own campaign" do
    patch api_v1_campaign_url(@campaign), params: {
      campaign: { title: "Updated Title" }
    }, as: :json
    assert_response :success
    assert_equal "Updated Title", @campaign.reload.title
  end

  test "should not update another user's campaign" do
    other_user = users(:two)
    other_campaign = campaigns(:two)
    sign_in other_user
    patch api_v1_campaign_url(@campaign), params: {
      campaign: { title: "Hacked" }
    }, as: :json
    assert_response :forbidden
  end

  test "admin can update any campaign" do
    sign_in @admin
    patch api_v1_campaign_url(@campaign), params: {
      campaign: { title: "Admin Updated" }
    }, as: :json
    assert_response :success
    assert_equal "Admin Updated", @campaign.reload.title
  end

  test "should destroy own campaign" do
    assert_difference('Campaign.count', -1) do
      delete api_v1_campaign_url(@campaign), as: :json
    end
    assert_response :success
  end

  test "should not destroy another user's campaign" do
    other_user = users(:two)
    other_campaign = campaigns(:two)
    sign_in other_user
    assert_no_difference('Campaign.count') do
      delete api_v1_campaign_url(@campaign), as: :json
    end
    assert_response :forbidden
  end

  test "admin can destroy any campaign" do
    sign_in @admin
    assert_difference('Campaign.count', -1) do
      delete api_v1_campaign_url(@campaign), as: :json
    end
    assert_response :success
  end
end
