require "test_helper"

class Api::V1::DocumentDownloadsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:one)
    @campaign = campaigns(:one)
    @investor = users(:two)
    @admin = users(:three)
    
    # Attach a test pitch deck to the campaign
    @campaign.pitch_deck.attach(
      io: StringIO.new("test pitch deck content"),
      filename: "pitch_deck.pdf",
      content_type: "application/pdf"
    )
    
    # Create a confirmed investment for the investor
    @investment = Investment.create!(
      user: @investor,
      campaign: @campaign,
      amount: 1000.00,
      status: 'confirmed'
    )
  end

  test "should allow campaign owner to download pitch deck" do
    sign_in @user
    get "/api/v1/campaigns/#{@campaign.id}/documents/pitch_deck"
    
    assert_response :success
    assert_equal "application/pdf", response.content_type
    assert_equal "attachment; filename=\"#{@campaign.title.parameterize}_pitch_deck.pdf\"", response.headers["Content-Disposition"]
  end

  test "should allow confirmed investor to download pitch deck" do
    sign_in @investor
    get "/api/v1/campaigns/#{@campaign.id}/documents/pitch_deck"
    
    assert_response :success
    assert_equal "application/pdf", response.content_type
  end

  test "should allow admin to download pitch deck" do
    @admin.update!(role: :admin)
    sign_in @admin
    get "/api/v1/campaigns/#{@campaign.id}/documents/pitch_deck"
    
    assert_response :success
    assert_equal "application/pdf", response.content_type
  end

  test "should deny access to non-investor users" do
    non_investor = users(:three)
    sign_in non_investor
    get "/api/v1/campaigns/#{@campaign.id}/documents/pitch_deck"
    
    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal "Access denied. Only confirmed investors can download documents.", json_response["status"]["message"]
  end

  test "should deny access to unconfirmed investors" do
    # Create a pending investment
    pending_investment = Investment.create!(
      user: users(:three),
      campaign: @campaign,
      amount: 500.00,
      status: 'pending'
    )
    
    sign_in users(:three)
    get "/api/v1/campaigns/#{@campaign.id}/documents/pitch_deck"
    
    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal "Access denied. Only confirmed investors can download documents.", json_response["status"]["message"]
  end

  test "should return 404 for non-existent campaign" do
    sign_in @user
    get "/api/v1/campaigns/999999/documents/pitch_deck"
    
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Campaign not found.", json_response["status"]["message"]
  end

  test "should return 404 for campaign without pitch deck" do
    campaign_without_deck = campaigns(:two)
    sign_in @user
    
    get "/api/v1/campaigns/#{campaign_without_deck.id}/documents/pitch_deck"
    
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Pitch deck not found.", json_response["status"]["message"]
  end

  test "should return 400 for invalid document type" do
    sign_in @user
    get "/api/v1/campaigns/#{@campaign.id}/documents/invalid_type"
    
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Invalid document type.", json_response["status"]["message"]
  end

  test "should require authentication" do
    get "/api/v1/campaigns/#{@campaign.id}/documents/pitch_deck"
    
    assert_response :unauthorized
  end

  test "should allow campaign owner to download KYC documents" do
    # Create KYC for the campaign owner
    kyc = Kyc.create!(
      user: @user,
      id_number: "123456789",
      phone: "+1234567890",
      address: "123 Test St",
      status: 'approved'
    )
    
    # Attach documents to KYC
    kyc.documents.attach(
      io: StringIO.new("test document content"),
      filename: "document1.pdf",
      content_type: "application/pdf"
    )
    
    sign_in @user
    get "/api/v1/campaigns/#{@campaign.id}/documents/kyc_documents"
    
    assert_response :success
    assert_equal "application/zip", response.content_type
    assert_equal "attachment; filename=\"#{@user.email}_kyc_documents.zip\"", response.headers["Content-Disposition"]
  end

  test "should allow admin to download KYC documents" do
    @admin.update!(role: :admin)
    
    # Create KYC for the campaign owner
    kyc = Kyc.create!(
      user: @user,
      id_number: "123456789",
      phone: "+1234567890",
      address: "123 Test St",
      status: 'approved'
    )
    
    # Attach documents to KYC
    kyc.documents.attach(
      io: StringIO.new("test document content"),
      filename: "document1.pdf",
      content_type: "application/pdf"
    )
    
    sign_in @admin
    get "/api/v1/campaigns/#{@campaign.id}/documents/kyc_documents"
    
    assert_response :success
    assert_equal "application/zip", response.content_type
  end

  test "should deny investor access to KYC documents" do
    sign_in @investor
    get "/api/v1/campaigns/#{@campaign.id}/documents/kyc_documents"
    
    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal "Access denied. Only campaign owner and admins can access KYC documents.", json_response["status"]["message"]
  end

  test "should return 404 for KYC documents when not available" do
    sign_in @user
    get "/api/v1/campaigns/#{@campaign.id}/documents/kyc_documents"
    
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "KYC documents not found.", json_response["status"]["message"]
  end

  test "should set secure headers for pitch deck download" do
    sign_in @user
    get "/api/v1/campaigns/#{@campaign.id}/documents/pitch_deck"
    
    assert_response :success
    assert_equal "nosniff", response.headers["X-Content-Type-Options"]
    assert_equal "DENY", response.headers["X-Frame-Options"]
  end

  test "should set secure headers for KYC documents download" do
    @admin.update!(role: :admin)
    
    # Create KYC with documents
    kyc = Kyc.create!(
      user: @user,
      id_number: "123456789",
      phone: "+1234567890",
      address: "123 Test St",
      status: 'approved'
    )
    
    kyc.documents.attach(
      io: StringIO.new("test document content"),
      filename: "document1.pdf",
      content_type: "application/pdf"
    )
    
    sign_in @admin
    get "/api/v1/campaigns/#{@campaign.id}/documents/kyc_documents"
    
    assert_response :success
    assert_equal "nosniff", response.headers["X-Content-Type-Options"]
    assert_equal "DENY", response.headers["X-Frame-Options"]
  end
end 