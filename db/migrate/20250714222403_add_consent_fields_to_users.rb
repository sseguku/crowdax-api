class AddConsentFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :consent_given_at, :datetime
    add_column :users, :consent_withdrawn_at, :datetime
    add_column :users, :consent_version, :string
  end
end
