class KycSerializer
  include JSONAPI::Serializer

  attributes :id, :user_id, :status, :created_at, :updated_at

  # Only include sensitive data for authorized users
  attribute :id_number do |object, params|
    if params[:current_user]&.admin? || params[:current_user]&.id == object.user_id
      object.id_number
    else
      nil
    end
  end

  attribute :phone do |object, params|
    if params[:current_user]&.admin? || params[:current_user]&.id == object.user_id
      object.phone
    else
      nil
    end
  end

  attribute :address do |object, params|
    if params[:current_user]&.admin? || params[:current_user]&.id == object.user_id
      object.address
    else
      nil
    end
  end

  attribute :status do |object|
    object.status
  end

  attribute :user do |object|
    {
      id: object.user.id,
      email: object.user.email,
      role: object.user.role
    }
  end

  # Secure document access with encryption
  attribute :documents do |object, params|
    if params[:current_user]&.admin? || params[:current_user]&.id == object.user_id
      object.documents.map do |doc|
        {
          id: doc.id,
          filename: doc.filename.to_s,
          content_type: doc.content_type,
          byte_size: doc.byte_size,
          encrypted: doc.blob.metadata['encrypted'] || false,
          # Only provide download URL for authorized users
          download_url: Rails.application.routes.url_helpers.rails_blob_url(doc, only_path: true)
        }
      end
    else
      []
    end
  end

  attribute :docs_metadata do |object, params|
    if params[:current_user]&.admin? || params[:current_user]&.id == object.user_id
      object.docs_metadata
    else
      nil
    end
  end
end 