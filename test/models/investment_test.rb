require "test_helper"

class InvestmentTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @campaign = campaigns(:one)
    
    # Ensure campaign has a pitch deck for validations
    unless @campaign.pitch_deck.attached?
      @campaign.pitch_deck.attach(
        io: StringIO.new("test pitch deck content"),
        filename: "pitch_deck.pdf",
        content_type: "application/pdf"
      )
    end
    
    # Delete any existing investments for this user/campaign to avoid conflicts
    Investment.where(user: @user, campaign: @campaign).destroy_all
    
    @investment = Investment.new(
      user: @user,
      campaign: @campaign,
      amount: 1000.00,
      status: 'pending'
    )
  end

  test "should be valid with valid attributes" do
    assert @investment.valid?
  end

  test "should require user" do
    @investment.user = nil
    assert_not @investment.valid?
    assert_includes @investment.errors[:user], "must exist"
  end

  test "should require campaign" do
    @investment.campaign = nil
    assert_not @investment.valid?
    assert_includes @investment.errors[:campaign], "must exist"
  end

  test "should require amount" do
    @investment.amount = nil
    assert_not @investment.valid?
    assert_includes @investment.errors[:amount], "can't be blank"
  end

  test "should validate amount is positive" do
    @investment.amount = 0
    assert_not @investment.valid?
    assert_includes @investment.errors[:amount], "must be greater than 0"
    
    @investment.amount = -100
    assert_not @investment.valid?
    assert_includes @investment.errors[:amount], "must be greater than 0"
  end

  test "should require status" do
    @investment.status = nil
    assert_not @investment.valid?
    assert_includes @investment.errors[:status], "can't be blank"
  end

  test "should validate status inclusion" do
    assert_raises(ArgumentError) do
      @investment.status = "invalid_status"
    end
  end

  test "should accept valid statuses" do
    valid_statuses = ["pending", "confirmed", "cancelled", "refunded"]
    valid_statuses.each do |status|
      @investment.status = status
      assert @investment.valid?, "#{status} should be valid"
    end
  end

  test "should prevent duplicate investments by same user in same campaign" do
    @investment.save!
    
    duplicate_investment = Investment.new(
      user: @user,
      campaign: @campaign,
      amount: 500.00,
      status: 'pending'
    )
    
    assert_not duplicate_investment.valid?
    assert_includes duplicate_investment.errors[:user_id], "has already invested in this campaign"
  end

  test "should allow different users to invest in same campaign" do
    @investment.save!
    
    other_user = users(:two)
    # Clear any existing investments for this user/campaign
    Investment.where(user: other_user, campaign: @campaign).destroy_all
    
    other_investment = Investment.new(
      user: other_user,
      campaign: @campaign,
      amount: 500.00,
      status: 'pending'
    )
    
    assert other_investment.valid?
  end

  test "should allow same user to invest in different campaigns" do
    @investment.save!
    
    other_campaign = campaigns(:two)
    # Ensure other campaign has pitch deck
    unless other_campaign.pitch_deck.attached?
      other_campaign.pitch_deck.attach(
        io: StringIO.new("test pitch deck content"),
        filename: "pitch_deck.pdf",
        content_type: "application/pdf"
      )
    end
    
    # Clear any existing investments for this user/other_campaign
    Investment.where(user: @user, campaign: other_campaign).destroy_all
    
    other_investment = Investment.new(
      user: @user,
      campaign: other_campaign,
      amount: 500.00,
      status: 'pending'
    )
    
    assert other_investment.valid?
  end

  test "should set default status to pending" do
    @investment.status = nil
    @investment.save!
    assert_equal "pending", @investment.status
  end

  test "should belong to user" do
    assert_respond_to @investment, :user
  end

  test "should belong to campaign" do
    assert_respond_to @investment, :campaign
  end

  test "status enum methods" do
    @investment.save!
    assert @investment.pending?
    @investment.confirmed!
    assert @investment.confirmed?
    @investment.cancelled!
    assert @investment.cancelled?
    @investment.refunded!
    assert @investment.refunded?
  end

  test "confirmed? method" do
    @investment.status = "confirmed"
    assert @investment.confirmed?
    
    @investment.status = "pending"
    assert_not @investment.confirmed?
  end

  test "can_be_confirmed? method" do
    @investment.status = "pending"
    @campaign.campaign_status = "approved"
    assert @investment.can_be_confirmed?
    
    @investment.status = "confirmed"
    assert_not @investment.can_be_confirmed?
    
    @investment.status = "pending"
    @campaign.campaign_status = "draft"
    assert_not @investment.can_be_confirmed?
  end

  test "can_be_cancelled? method" do
    @investment.status = "pending"
    assert @investment.can_be_cancelled?
    
    @investment.status = "confirmed"
    assert_not @investment.can_be_cancelled?
  end

  test "can_be_refunded? method" do
    @investment.status = "confirmed"
    assert @investment.can_be_refunded?
    
    @investment.status = "pending"
    assert_not @investment.can_be_refunded?
  end

  test "scopes" do
    @investment.save!
    
    # Test confirmed scope
    other_user = users(:two)
    Investment.where(user: other_user, campaign: @campaign).destroy_all
    
    confirmed_investment = Investment.new(
      user: other_user,
      campaign: @campaign,
      amount: 2000.00,
      status: 'confirmed'
    )
    confirmed_investment.save!
    
    assert_equal 1, Investment.confirmed.count
    assert_includes Investment.confirmed, confirmed_investment
    
    # Test by_campaign scope
    campaign_investments = Investment.by_campaign(@campaign.id)
    assert_equal 2, campaign_investments.count
    assert_includes campaign_investments, @investment
    assert_includes campaign_investments, confirmed_investment
    
    # Test by_investor scope
    user_investments = Investment.by_investor(@user.id)
    assert_equal 1, user_investments.count
    assert_includes user_investments, @investment
  end

  test "should update campaign current_amount when investment is confirmed" do
    @campaign.update!(current_amount: 0)
    @investment.amount = 1000
    @investment.status = "confirmed"
    @investment.save!
    
    @campaign.reload
    assert_equal 1000, @campaign.current_amount
  end

  test "should update campaign current_amount when investment status changes from confirmed" do
    @campaign.update!(current_amount: 1000)
    @investment.amount = 1000
    @investment.status = "confirmed"
    @investment.save!
    
    @campaign.reload
    assert_equal 2000, @campaign.current_amount
    
    @investment.status = "cancelled"
    @investment.save!
    
    @campaign.reload
    assert_equal 0, @campaign.current_amount
  end
end
