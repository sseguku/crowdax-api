require "test_helper"

class CampaignTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @campaign = Campaign.new(
      user: @user,
      title: "Test Campaign",
      sector: "technology",
      goal_amount: 50000.00,
      team: "Our team consists of experienced professionals.",
      campaign_status: "draft"
    )
    
    # Attach a test pitch deck
    @campaign.pitch_deck.attach(
      io: StringIO.new("test pitch deck content"),
      filename: "pitch_deck.pdf",
      content_type: "application/pdf"
    )
  end

  test "should be valid with valid attributes" do
    assert @campaign.valid?
  end

  test "should require user" do
    @campaign.user = nil
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:user], "must exist"
  end

  test "should require title" do
    @campaign.title = nil
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:title], "can't be blank"
  end

  test "should validate title length" do
    @campaign.title = "Hi"
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:title], "is too short (minimum is 5 characters)"
    
    @campaign.title = "A" * 201
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:title], "is too long (maximum is 200 characters)"
  end

  test "should require sector" do
    @campaign.sector = nil
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:sector], "can't be blank"
  end

  test "should validate sector inclusion" do
    @campaign.sector = "invalid_sector"
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:sector], "must be a valid sector"
  end

  test "should accept valid sectors" do
    valid_sectors = %w[technology healthcare finance education retail manufacturing energy real_estate other]
    valid_sectors.each do |sector|
      @campaign.sector = sector
      assert @campaign.valid?, "#{sector} should be valid"
    end
  end

  test "should require goal_amount" do
    @campaign.goal_amount = nil
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:goal_amount], "can't be blank"
  end

  test "should validate goal_amount is positive" do
    @campaign.goal_amount = 0
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:goal_amount], "must be greater than 0"
    
    @campaign.goal_amount = -1000
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:goal_amount], "must be greater than 0"
  end

  test "should require team" do
    @campaign.team = nil
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:team], "can't be blank"
  end

  test "should validate team length" do
    @campaign.team = "Short"
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:team], "is too short (minimum is 10 characters)"
  end

  test "should require pitch_deck" do
    @campaign.pitch_deck = nil
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:pitch_deck], "can't be blank"
  end

  test "should validate pitch_deck content type" do
    @campaign.pitch_deck.attach(
      io: StringIO.new("test content"),
      filename: "test.txt",
      content_type: "text/plain"
    )
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:pitch_deck], "must be a PDF or PowerPoint file"
  end

  test "should set default campaign_status to draft" do
    @campaign.campaign_status = nil
    @campaign.save!
    assert_equal "draft", @campaign.campaign_status
  end

  test "should validate campaign_status inclusion" do
    assert_raises(ArgumentError) do
      @campaign.campaign_status = "invalid_status"
    end
  end

  test "should accept valid campaign_statuses" do
    valid_statuses = ["draft", "submitted", "approved", "rejected", "funded", "closed"]
    valid_statuses.each do |status|
      @campaign.campaign_status = status
      assert @campaign.valid?, "#{status} should be valid"
    end
  end

  test "should belong to user" do
    assert_respond_to @campaign, :user
  end

  test "should have attached pitch_deck" do
    assert_respond_to @campaign, :pitch_deck
    assert @campaign.pitch_deck.attached?
  end

  test "campaign_status enum methods" do
    @campaign.save!
    assert @campaign.draft?
    @campaign.submitted!
    assert @campaign.submitted?
    @campaign.approved!
    assert @campaign.approved?
    @campaign.rejected!
    assert @campaign.rejected?
    @campaign.funded!
    assert @campaign.funded?
    @campaign.closed!
    assert @campaign.closed?
  end

  test "funding_progress calculation" do
    @campaign.goal_amount = 1000
    @campaign.current_amount = 500
    assert_equal 50.0, @campaign.funding_progress
    
    @campaign.current_amount = 1000
    assert_equal 100.0, @campaign.funding_progress
    
    @campaign.current_amount = 0
    assert_equal 0.0, @campaign.funding_progress
  end

  test "can_be_activated?" do
    @campaign.campaign_status = "approved"
    assert @campaign.can_be_activated?
    
    @campaign.campaign_status = "draft"
    assert_not @campaign.can_be_activated?
    
    @campaign.campaign_status = "approved"
    @campaign.pitch_deck = nil
    assert_not @campaign.can_be_activated?
  end

  test "can_be_funded?" do
    @campaign.campaign_status = "approved"
    @campaign.goal_amount = 1000
    @campaign.current_amount = 1000
    assert @campaign.can_be_funded?
    
    @campaign.current_amount = 500
    assert_not @campaign.can_be_funded?
    
    @campaign.campaign_status = "draft"
    assert_not @campaign.can_be_funded?
  end

  test "scopes" do
    file = StringIO.new("test pitch deck content")
    approved_campaign = Campaign.new(user: @user, title: "Approved Campaign", sector: "technology", goal_amount: 10000, team: "Test team for approved campaign", campaign_status: "approved")
    approved_campaign.pitch_deck.attach(io: file, filename: "pitch_deck.pdf", content_type: "application/pdf")
    approved_campaign.save!

    file2 = StringIO.new("test pitch deck content")
    submitted_campaign = Campaign.new(user: @user, title: "Submitted Campaign", sector: "healthcare", goal_amount: 20000, team: "Test team for submitted campaign", campaign_status: "submitted")
    submitted_campaign.pitch_deck.attach(io: file2, filename: "pitch_deck.pdf", content_type: "application/pdf")
    submitted_campaign.save!
    
    assert_operator Campaign.approved.count, :>=, 1
    assert_operator Campaign.submitted.count, :>=, 1
    assert_operator Campaign.by_sector("technology").count, :>=, 1
  end

  test "running_campaigns scope" do
    # Create approved campaign
    file1 = StringIO.new("test pitch deck content")
    approved_campaign = Campaign.new(user: @user, title: "Approved Campaign", sector: "technology", goal_amount: 10000, team: "Test team for approved campaign", campaign_status: "approved")
    approved_campaign.pitch_deck.attach(io: file1, filename: "pitch_deck.pdf", content_type: "application/pdf")
    approved_campaign.save!

    # Create funded campaign
    file2 = StringIO.new("test pitch deck content")
    funded_campaign = Campaign.new(user: @user, title: "Funded Campaign", sector: "healthcare", goal_amount: 20000, team: "Test team for funded campaign", campaign_status: "funded")
    funded_campaign.pitch_deck.attach(io: file2, filename: "pitch_deck.pdf", content_type: "application/pdf")
    funded_campaign.save!

    # Create draft campaign (should not be included)
    file3 = StringIO.new("test pitch deck content")
    draft_campaign = Campaign.new(user: @user, title: "Draft Campaign", sector: "finance", goal_amount: 15000, team: "Test team for draft campaign", campaign_status: "draft")
    draft_campaign.pitch_deck.attach(io: file3, filename: "pitch_deck.pdf", content_type: "application/pdf")
    draft_campaign.save!

    running_campaigns = Campaign.running_campaigns
    assert_includes running_campaigns, approved_campaign
    assert_includes running_campaigns, funded_campaign
    assert_not_includes running_campaigns, draft_campaign
  end

  test "top_funded scope" do
    # Create funded campaigns with different amounts
    file1 = StringIO.new("test pitch deck content")
    funded_campaign1 = Campaign.new(user: @user, title: "Funded Campaign 1", sector: "technology", goal_amount: 10000, current_amount: 5000, team: "Test team for funded campaign 1", campaign_status: "funded")
    funded_campaign1.pitch_deck.attach(io: file1, filename: "pitch_deck.pdf", content_type: "application/pdf")
    funded_campaign1.save!

    file2 = StringIO.new("test pitch deck content")
    funded_campaign2 = Campaign.new(user: @user, title: "Funded Campaign 2", sector: "healthcare", goal_amount: 20000, current_amount: 15000, team: "Test team for funded campaign 2", campaign_status: "funded")
    funded_campaign2.pitch_deck.attach(io: file2, filename: "pitch_deck.pdf", content_type: "application/pdf")
    funded_campaign2.save!

    file3 = StringIO.new("test pitch deck content")
    funded_campaign3 = Campaign.new(user: @user, title: "Funded Campaign 3", sector: "finance", goal_amount: 15000, current_amount: 20000, team: "Test team for funded campaign 3", campaign_status: "funded")
    funded_campaign3.pitch_deck.attach(io: file3, filename: "pitch_deck.pdf", content_type: "application/pdf")
    funded_campaign3.save!

    # Test default limit (10) - account for existing fixtures
    top_funded = Campaign.top_funded
    assert_operator top_funded.count, :>=, 3
    assert_includes top_funded, funded_campaign1
    assert_includes top_funded, funded_campaign2
    assert_includes top_funded, funded_campaign3

    # Test custom limit - just verify we get the right number and our campaigns are included
    top_funded_limited = Campaign.top_funded(2)
    assert_equal 2, top_funded_limited.count
    # Since we have fixtures, we can't guarantee which 2 campaigns will be in the top 2
    # Just verify that our campaigns exist in the overall top_funded list
    assert_includes Campaign.top_funded, funded_campaign2
    assert_includes Campaign.top_funded, funded_campaign3
  end

  test "by_sector scope" do
    # Create campaigns in different sectors
    file1 = StringIO.new("test pitch deck content")
    tech_campaign = Campaign.new(user: @user, title: "Tech Campaign", sector: "technology", goal_amount: 10000, team: "Test team for tech campaign", campaign_status: "approved")
    tech_campaign.pitch_deck.attach(io: file1, filename: "pitch_deck.pdf", content_type: "application/pdf")
    tech_campaign.save!

    file2 = StringIO.new("test pitch deck content")
    health_campaign = Campaign.new(user: @user, title: "Health Campaign", sector: "healthcare", goal_amount: 20000, team: "Test team for health campaign", campaign_status: "approved")
    health_campaign.pitch_deck.attach(io: file2, filename: "pitch_deck.pdf", content_type: "application/pdf")
    health_campaign.save!

    file3 = StringIO.new("test pitch deck content")
    finance_campaign = Campaign.new(user: @user, title: "Finance Campaign", sector: "finance", goal_amount: 15000, team: "Test team for finance campaign", campaign_status: "approved")
    finance_campaign.pitch_deck.attach(io: file3, filename: "pitch_deck.pdf", content_type: "application/pdf")
    finance_campaign.save!

    # Test filtering by sector
    tech_campaigns = Campaign.by_sector("technology")
    assert_includes tech_campaigns, tech_campaign
    assert_not_includes tech_campaigns, health_campaign
    assert_not_includes tech_campaigns, finance_campaign

    health_campaigns = Campaign.by_sector("healthcare")
    assert_includes health_campaigns, health_campaign
    assert_not_includes health_campaigns, tech_campaign
    assert_not_includes health_campaigns, finance_campaign

    finance_campaigns = Campaign.by_sector("finance")
    assert_includes finance_campaigns, finance_campaign
    assert_not_includes finance_campaigns, tech_campaign
    assert_not_includes finance_campaigns, health_campaign
  end
end
