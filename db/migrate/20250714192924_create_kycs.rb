class CreateKycs < ActiveRecord::Migration[8.0]
  def change
    create_table :kycs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :id_number
      t.json :docs
      t.string :phone
      t.text :address
      t.string :status

      t.timestamps
    end
  end
end
