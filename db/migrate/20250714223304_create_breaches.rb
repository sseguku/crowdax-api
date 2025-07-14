class CreateBreaches < ActiveRecord::Migration[8.0]
  def change
    create_table :breaches do |t|
      t.references :user, null: true, foreign_key: true
      t.string :breach_type, null: false
      t.string :severity, null: false
      t.text :description, null: false
      t.datetime :detected_at, null: false
      t.datetime :resolved_at
      t.string :status, default: 'open'
      t.json :metadata
      t.string :ip_address
      t.string :user_agent
      t.text :affected_data
      t.integer :affected_records_count

      t.timestamps
    end

    add_index :breaches, :breach_type
    add_index :breaches, :severity
    add_index :breaches, :status
    add_index :breaches, :detected_at
  end
end
