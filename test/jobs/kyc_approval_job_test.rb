require "test_helper"

class KycApprovalJobTest < ActiveJob::TestCase
  def setup
    @kyc = kycs(:one)
    @kyc.update!(status: 'pending')
  end

  test "should approve pending kyc" do
    assert_equal 'pending', @kyc.status
    
    KycApprovalJob.perform_now(@kyc.id)
    
    @kyc.reload
    assert_equal 'approved', @kyc.status
  end

  test "should not approve non-pending kyc" do
    @kyc.update!(status: 'approved')
    
    KycApprovalJob.perform_now(@kyc.id)
    
    @kyc.reload
    assert_equal 'approved', @kyc.status
  end

  test "should handle non-existent kyc" do
    assert_nothing_raised do
      KycApprovalJob.perform_now(999999)
    end
  end

  test "should enqueue job" do
    assert_enqueued_with(job: KycApprovalJob, args: [@kyc.id]) do
      KycApprovalJob.perform_async(@kyc.id)
    end
  end
end 