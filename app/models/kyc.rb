class Kyc < ApplicationRecord
  include EncryptedAttachments
  
  belongs_to :user

  # Attachments
  has_many_attached :documents

  # Encrypted attributes
  encrypts :id_number
  encrypts :phone
  encrypts :address
  encrypts :docs_metadata

  # Enums
  enum :status, {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected',
    under_review: 'under_review'
  }

  # Validations
  validates :id_number, presence: true, uniqueness: true
  validates :phone, presence: true, format: { with: /\A\+?[\d\s\-\(\)]+\z/, message: "must be a valid phone number" }
  validates :address, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :documents, presence: true

  # Callbacks
  before_validation :set_default_status, on: :create
  after_save :encrypt_attachments_metadata

  # Scopes
  scope :pending_review, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :under_review, -> { where(status: 'under_review') }

  private

  def set_default_status
    self.status ||= 'pending'
  end

  def encrypt_attachments_metadata
    return unless documents.attached?

    metadata = documents.map do |document|
      {
        filename: document.filename.to_s,
        content_type: document.content_type,
        byte_size: document.byte_size,
        checksum: document.checksum,
        created_at: document.created_at,
        # Encrypt the actual file content reference
        encrypted_blob_id: document.blob.id
      }
    end

    update_column(:docs_metadata, metadata.to_json)
  end
end
