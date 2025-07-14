class CampaignSerializer
  include JSONAPI::Serializer

  attributes :id, :title, :sector, :goal_amount, :team, :campaign_status, :created_at, :updated_at

  attribute :campaign_status do |object|
    object.campaign_status
  end

  attribute :user do |object|
    {
      id: object.user.id,
      email: object.user.email,
      role: object.user.role
    }
  end

  attribute :pitch_deck_url do |object|
    if object.pitch_deck.attached?
      Rails.application.routes.url_helpers.rails_blob_url(object.pitch_deck, only_path: true)
    else
      nil
    end
  end

  attribute :funding_progress do |object|
    object.funding_progress
  end

  attribute :can_be_activated do |object|
    object.can_be_activated?
  end

  attribute :can_be_funded do |object|
    object.can_be_funded?
  end
end 