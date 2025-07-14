require "test_helper"

class DataDeletionRequestTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @deletion_request = DataDeletionRequest.new(
      user: @user,
      reason: "I no longer want my data to be processed by this platform",
      status: 'pending'
    )
  end

  test "should be valid with valid attributes" do
    assert @deletion_request.valid?
  end

  test "should require user" do
    @deletion_request.user = nil
    assert_not @deletion_request.valid?
    assert_includes @deletion_request.errors[:user], "must exist"
  end

  test "should require reason" do
    @deletion_request.reason = nil
    assert_not @deletion_request.valid?
    assert_includes @deletion_request.errors[:reason], "can't be blank"
  end

  test "should require minimum reason length" do
    @deletion_request.reason = "Short"
    assert_not @deletion_request.valid?
    assert_includes @deletion_request.errors[:reason], "is too short (minimum is 10 characters)"
  end

  test "should set defaults on creation" do
    deletion_request = DataDeletionRequest.create!(
      user: @user,
      reason: "Valid reason for data deletion request"
    )
    
    assert_equal 'pending', deletion_request.status
    assert_not_nil deletion_request.requested_at
    assert_not_nil deletion_request.estimated_completion_date
  end

  test "should log deletion request on creation" do
    assert_difference 'TransactionLog.count' do
      @deletion_request.save!
    end
    
    log = TransactionLog.last
    assert_equal 'data_deletion_requested', log.action
    assert_equal @user, log.user
    assert_equal 'DataDeletionRequest', log.record_type
    assert_equal @deletion_request.id, log.record_id
  end

  test "should approve deletion request" do
    @deletion_request.save!
    admin_user = users(:admin)
    
    @deletion_request.approve!(admin_user, "Approved after review")
    
    assert_equal 'approved', @deletion_request.status
    assert_not_nil @deletion_request.processed_at
    assert_equal admin_user.email, @deletion_request.processed_by
    assert_equal "Approved after review", @deletion_request.admin_notes
  end

  test "should reject deletion request" do
    @deletion_request.save!
    admin_user = users(:admin)
    
    @deletion_request.reject!(admin_user, "Cannot delete due to regulatory requirements")
    
    assert_equal 'rejected', @deletion_request.status
    assert_not_nil @deletion_request.processed_at
    assert_equal admin_user.email, @deletion_request.processed_by
    assert_equal "Cannot delete due to regulatory requirements", @deletion_request.admin_notes
  end

  test "should complete deletion request" do
    @deletion_request.save!
    
    @deletion_request.complete!
    
    assert_equal 'completed', @deletion_request.status
    assert_not_nil @deletion_request.processed_at
  end

  test "should put deletion request on hold" do
    @deletion_request.save!
    
    @deletion_request.put_on_hold!("Regulatory investigation in progress")
    
    assert_equal 'on_hold', @deletion_request.status
    assert @deletion_request.regulatory_hold
    assert_equal "Regulatory investigation in progress", @deletion_request.hold_reason
  end

  test "should calculate days since request" do
    @deletion_request.requested_at = 5.days.ago
    @deletion_request.save!
    
    assert_equal 5, @deletion_request.days_since_request
  end

  test "should detect overdue requests" do
    @deletion_request.requested_at = 31.days.ago
    @deletion_request.save!
    
    assert @deletion_request.is_overdue?
  end

  test "should check if can be processed" do
    @deletion_request.save!
    assert @deletion_request.can_be_processed?
    
    @deletion_request.put_on_hold!("Hold reason")
    assert_not @deletion_request.can_be_processed?
    
    @deletion_request.update!(regulatory_hold: false, status: 'approved')
    assert_not @deletion_request.can_be_processed?
  end

  test "should scope by status" do
    @deletion_request.save!
    approved_request = DataDeletionRequest.create!(
      user: @user,
      reason: "Another valid reason",
      status: 'approved'
    )
    
    assert_includes DataDeletionRequest.pending, @deletion_request
    assert_includes DataDeletionRequest.approved, approved_request
  end

  test "should scope recent requests" do
    @deletion_request.save!
    old_request = DataDeletionRequest.create!(
      user: @user,
      reason: "Old request",
      requested_at: 31.days.ago
    )
    
    assert_includes DataDeletionRequest.recent, @deletion_request
    assert_not_includes DataDeletionRequest.recent, old_request
  end

  test "should scope regulatory holds" do
    @deletion_request.put_on_hold!("Regulatory hold")
    @deletion_request.save!
    
    assert_includes DataDeletionRequest.regulatory_hold, @deletion_request
  end
end
