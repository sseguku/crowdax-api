class CreateCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :campaigns do |t|
      t.string :title
      t.string :sector
      t.decimal :goal_amount
      t.string :pitch_deck
      t.text :team
      t.string :status

      t.timestamps
    end
  end
end
