class AddDocsMetadataToKycs < ActiveRecord::Migration[8.0]
  def change
    add_column :kycs, :docs_metadata, :text
  end
end
