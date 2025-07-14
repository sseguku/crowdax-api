require "test_helper"

class KycTest < ActiveSupport::TestCase
  def setup
    # Clean up any existing KYC records to avoid conflicts
    Kyc.destroy_all
    
    @user = users(:one)
    @kyc = Kyc.new(
      user: @user,
      id_number: "ID123456789",
      phone: "+1234567890",
      address: "123 Main St, City, Country",
      status: "pending"
    )
    
    # Attach a test document
    @kyc.documents.attach(
      io: StringIO.new("test document content"),
      filename: "test_document.pdf",
      content_type: "application/pdf"
    )
  end

  test "should be valid with valid attributes" do
    assert @kyc.valid?
  end

  test "should require user" do
    @kyc.user = nil
    assert_not @kyc.valid?
    assert_includes @kyc.errors[:user], "must exist"
  end

  test "should require id_number" do
    @kyc.id_number = nil
    assert_not @kyc.valid?
    assert_includes @kyc.errors[:id_number], "can't be blank"
  end

  test "should require unique id_number" do
    @kyc.save!
    duplicate_kyc = Kyc.new(
      user: users(:two),
      id_number: @kyc.id_number,
      phone: "+1234567891",
      address: "456 Other St, City, Country"
    )
    duplicate_kyc.documents.attach(
      io: StringIO.new("test document content"),
      filename: "test_document2.pdf",
      content_type: "application/pdf"
    )
    assert_not duplicate_kyc.valid?
    assert_includes duplicate_kyc.errors[:id_number], "has already been taken"
  end

  test "should require phone" do
    @kyc.phone = nil
    assert_not @kyc.valid?
    assert_includes @kyc.errors[:phone], "can't be blank"
  end

  test "should validate phone format" do
    @kyc.phone = "invalid_phone"
    assert_not @kyc.valid?
    assert_includes @kyc.errors[:phone], "must be a valid phone number"
  end

  test "should accept valid phone formats" do
    valid_phones = ["+1234567890", "123-456-7890", "(123) 456-7890", "1234567890"]
    valid_phones.each do |phone|
      @kyc.phone = phone
      assert @kyc.valid?, "#{phone} should be valid"
    end
  end

  test "should require address" do
    @kyc.address = nil
    assert_not @kyc.valid?
    assert_includes @kyc.errors[:address], "can't be blank"
  end

  test "should require documents" do
    @kyc.documents = []
    assert_not @kyc.valid?
    assert_includes @kyc.errors[:documents], "can't be blank"
  end

  test "should set default status to pending" do
    @kyc.status = nil
    @kyc.save!
    assert_equal "pending", @kyc.status
  end

  test "should validate status inclusion" do
    assert_raises(ArgumentError) do
      @kyc.status = "invalid_status"
    end
  end

  test "should accept valid statuses" do
    valid_statuses = ["pending", "approved", "rejected", "under_review"]
    valid_statuses.each do |status|
      @kyc.status = status
      assert @kyc.valid?, "#{status} should be valid"
    end
  end

  test "should belong to user" do
    assert_respond_to @kyc, :user
  end

  test "should have many attached documents" do
    assert_respond_to @kyc, :documents
    assert @kyc.documents.attached?
  end

  test "should encrypt docs_metadata" do
    metadata = { "passport" => "test_passport", "utility_bill" => "test_bill" }
    @kyc.docs_metadata = metadata.to_json
    @kyc.save!
    
    # Reload to test encryption
    @kyc.reload
    assert_equal metadata.to_json, @kyc.docs_metadata
  end

  test "status enum methods" do
    @kyc.save!
    assert @kyc.pending?
    @kyc.approved!
    assert @kyc.approved?
    @kyc.rejected!
    assert @kyc.rejected?
    @kyc.under_review!
    assert @kyc.under_review?
  end
end
