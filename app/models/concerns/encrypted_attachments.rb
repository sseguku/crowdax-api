module EncryptedAttachments
  extend ActiveSupport::Concern

  included do
    after_commit :encrypt_attachments, on: :create
    after_commit :encrypt_attachments, on: :update
  end

  private

  def encrypt_attachments
    return unless respond_to?(:documents) && documents.attached?

    storage_service = EncryptedStorageService.new

    documents.each do |document|
      next if document.blob.metadata['encrypted']

      # Read the original file content
      file_content = document.download

      # Encrypt the content
      encrypted_data = storage_service.encrypt_file(file_content)

      # Store encrypted metadata
      storage_service.store_encrypted_metadata(document.blob.id, encrypted_data)

      # Mark blob as encrypted
      document.blob.update(metadata: document.blob.metadata.merge('encrypted' => true))
    end
  end

  def decrypt_attachment(attachment)
    return attachment unless attachment.blob.metadata['encrypted']

    storage_service = EncryptedStorageService.new
    encrypted_data = storage_service.retrieve_encrypted_metadata(attachment.blob.id)

    return nil unless encrypted_data

    decrypted_content = storage_service.decrypt_file(encrypted_data)
    return nil unless decrypted_content

    # Create a temporary file with decrypted content
    temp_file = Tempfile.new(['decrypted', File.extname(attachment.filename.to_s)])
    temp_file.binmode
    temp_file.write(decrypted_content)
    temp_file.rewind

    # Create a new attachment-like object
    OpenStruct.new(
      filename: attachment.filename,
      content_type: attachment.content_type,
      temp_file: temp_file,
      download: -> { decrypted_content }
    )
  end
end 