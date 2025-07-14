class CreateInvestments < ActiveRecord::Migration[8.0]
  def change
    create_table :investments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :campaign, null: false, foreign_key: true
      t.decimal :amount
      t.string :status

      t.timestamps
    end
  end
end
