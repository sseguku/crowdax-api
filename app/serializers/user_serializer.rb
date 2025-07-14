class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :email, :role, :created_at, :updated_at

  attribute :created_date do |user|
    user.created_at&.strftime('%d/%m/%Y')
  end
end 