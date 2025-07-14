class CreateDataDeletionRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :data_deletion_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :requested_at, null: false
      t.text :reason
      t.string :status, default: 'pending'
      t.datetime :processed_at
      t.text :admin_notes
      t.string :processed_by
      t.json :data_types_requested
      t.datetime :estimated_completion_date
      t.boolean :regulatory_hold, default: false
      t.text :hold_reason

      t.timestamps
    end

    add_index :data_deletion_requests, :status
    add_index :data_deletion_requests, :requested_at
    add_index :data_deletion_requests, :processed_at
  end
end
