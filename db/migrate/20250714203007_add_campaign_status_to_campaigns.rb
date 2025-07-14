class AddCampaignStatusToCampaigns < ActiveRecord::Migration[8.0]
  def change
    add_column :campaigns, :campaign_status, :string
  end
end
