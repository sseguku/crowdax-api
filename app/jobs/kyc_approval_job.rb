class KycApprovalJob
  include Sidekiq::Job

  def perform(kyc_id)
    kyc = Kyc.find_by(id: kyc_id)
    return unless kyc && kyc.pending?
    kyc.update!(status: 'approved')
    # TODO: Notify user of approval (e.g., send email)
  end
end 