class AddEntrepreneurFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :company_name, :string
    add_column :users, :industry, :string
    add_column :users, :business_stage, :string
    add_column :users, :founded_date, :date
    add_column :users, :website, :string
    add_column :users, :business_description, :text
    add_column :users, :problem_being_solved, :text
    add_column :users, :target_market, :text
    add_column :users, :competitive_advantage, :text
    add_column :users, :funding_amount_needed, :decimal, precision: 15, scale: 2
    add_column :users, :funding_purpose, :text
    add_column :users, :current_annual_revenue_min, :decimal, precision: 15, scale: 2
    add_column :users, :current_annual_revenue_max, :decimal, precision: 15, scale: 2
    add_column :users, :projected_annual_revenue_min, :decimal, precision: 15, scale: 2
    add_column :users, :projected_annual_revenue_max, :decimal, precision: 15, scale: 2
    add_column :users, :team_size_min, :integer
    add_column :users, :team_size_max, :integer
    add_column :users, :number_of_co_founders, :integer
    add_column :users, :tin, :string
    add_column :users, :legal_structure, :string
    
    # Add indexes for better query performance
    add_index :users, :company_name
    add_index :users, :industry
    add_index :users, :business_stage
    add_index :users, :legal_structure
  end
end
