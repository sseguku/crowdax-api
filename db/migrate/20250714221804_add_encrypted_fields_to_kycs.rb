class AddEncryptedFieldsToKycs < ActiveRecord::Migration[8.0]
  def change
    # Remove old unencrypted fields
    remove_column :kycs, :id_number, :string
    remove_column :kycs, :phone, :string
    remove_column :kycs, :address, :text
    remove_column :kycs, :docs, :json

    # Add encrypted fields
    add_column :kycs, :encrypted_id_number, :string
    add_column :kycs, :encrypted_id_number_iv, :string
    add_column :kycs, :encrypted_phone, :string
    add_column :kycs, :encrypted_phone_iv, :string
    add_column :kycs, :encrypted_address, :text
    add_column :kycs, :encrypted_address_iv, :string
    add_column :kycs, :encrypted_docs_metadata, :text
    add_column :kycs, :encrypted_docs_metadata_iv, :string

    # Add indexes for encrypted fields
    add_index :kycs, :encrypted_id_number_iv, unique: true
    add_index :kycs, :encrypted_phone_iv, unique: true
    add_index :kycs, :encrypted_address_iv, unique: true
    add_index :kycs, :encrypted_docs_metadata_iv, unique: true
  end
end
