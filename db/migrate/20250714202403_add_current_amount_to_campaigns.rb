class AddCurrentAmountToCampaigns < ActiveRecord::Migration[8.0]
  def change
    add_column :campaigns, :current_amount, :decimal
  end
end
