class BreachSerializer
  include JSONAPI::Serializer

  attributes :id, :breach_type, :severity, :description, :detected_at, :resolved_at, :status, :ip_address, :user_agent, :affected_data, :affected_records_count, :metadata, :created_at, :updated_at

  attribute :breach_type do |object|
    object.breach_type.humanize
  end

  attribute :severity do |object|
    object.severity.humanize
  end

  attribute :status do |object|
    object.status.humanize
  end

  attribute :user do |object|
    if object.user
      {
        id: object.user.id,
        email: object.user.email,
        role: object.user.role
      }
    else
      nil
    end
  end

  attribute :duration do |object|
    object.duration&.to_i
  end

  attribute :is_open do |object|
    object.is_open?
  end

  attribute :is_critical do |object|
    object.is_critical?
  end

  attribute :formatted_detected_at do |object|
    object.detected_at.strftime("%B %d, %Y at %I:%M %p")
  end

  attribute :formatted_resolved_at do |object|
    object.resolved_at&.strftime("%B %d, %Y at %I:%M %p")
  end
end 