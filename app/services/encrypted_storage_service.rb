class EncryptedStorageService
  require 'openssl'
  require 'base64'

  def initialize
    @encryption_key = ENV['ENCRYPTION_KEY'] || Rails.application.credentials.encryption_key || generate_encryption_key
    @algorithm = 'AES-256-GCM'
  end

  # Encrypt file content before storing
  def encrypt_file(file_content)
    cipher = OpenSSL::Cipher.new(@algorithm)
    cipher.encrypt
    cipher.key = @encryption_key
    iv = cipher.random_iv

    encrypted_content = cipher.update(file_content) + cipher.final
    auth_tag = cipher.auth_tag

    {
      encrypted_content: Base64.strict_encode64(encrypted_content),
      iv: Base64.strict_encode64(iv),
      auth_tag: Base64.strict_encode64(auth_tag)
    }
  end

  # Decrypt file content for retrieval
  def decrypt_file(encrypted_data)
    cipher = OpenSSL::Cipher.new(@algorithm)
    cipher.decrypt
    cipher.key = @encryption_key
    cipher.iv = Base64.strict_decode64(encrypted_data[:iv])
    cipher.auth_tag = Base64.strict_decode64(encrypted_data[:auth_tag])
    cipher.auth_data = ""

    encrypted_content = Base64.strict_decode64(encrypted_data[:encrypted_content])
    cipher.update(encrypted_content) + cipher.final
  rescue OpenSSL::Cipher::CipherError => e
    Rails.logger.error "Failed to decrypt file: #{e.message}"
    nil
  end

  # Store encrypted file metadata
  def store_encrypted_metadata(blob_id, encrypted_data)
    Rails.cache.write("encrypted_blob_#{blob_id}", encrypted_data, expires_in: 1.hour)
  end

  # Retrieve encrypted file metadata
  def retrieve_encrypted_metadata(blob_id)
    Rails.cache.read("encrypted_blob_#{blob_id}")
  end

  private

  def generate_encryption_key
    SecureRandom.hex(32)
  end
end 