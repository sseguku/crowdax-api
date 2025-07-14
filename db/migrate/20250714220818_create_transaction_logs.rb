class CreateTransactionLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :transaction_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action
      t.string :record_type
      t.bigint :record_id
      t.json :details
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
