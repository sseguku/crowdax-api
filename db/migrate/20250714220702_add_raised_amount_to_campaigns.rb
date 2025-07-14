class AddRaisedAmountToCampaigns < ActiveRecord::Migration[8.0]
  def change
    add_column :campaigns, :raised_amount, :decimal
  end
end
