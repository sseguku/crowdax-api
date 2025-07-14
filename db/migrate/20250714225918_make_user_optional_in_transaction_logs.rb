class MakeUserOptionalInTransactionLogs < ActiveRecord::Migration[8.0]
  def change
    change_column_null :transaction_logs, :user_id, true
  end
end
