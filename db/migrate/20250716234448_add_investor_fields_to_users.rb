class AddInvestorFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    # Professional Information (Step 2)
    add_column :users, :job_title, :string
    add_column :users, :years_of_experience_min, :integer
    add_column :users, :years_of_experience_max, :integer
    
    # Investment Profile (Step 3)
    add_column :users, :typical_investment_amount_min, :decimal, precision: 15, scale: 2
    add_column :users, :typical_investment_amount_max, :decimal, precision: 15, scale: 2
    add_column :users, :investment_frequency, :string
    add_column :users, :preferred_industries, :text, array: true, default: []
    add_column :users, :preferred_investment_stages, :text, array: true, default: []
    
    # Financial & Risk Profile (Step 4)
    add_column :users, :annual_income_min, :decimal, precision: 15, scale: 2
    add_column :users, :annual_income_max, :decimal, precision: 15, scale: 2
    add_column :users, :net_worth_min, :decimal, precision: 15, scale: 2
    add_column :users, :net_worth_max, :decimal, precision: 15, scale: 2
    add_column :users, :accredited_investor, :boolean, default: false
    add_column :users, :risk_tolerance, :string
    add_column :users, :previous_investment_experience, :text
    add_column :users, :investment_goals, :text
    add_column :users, :minimum_investment, :decimal, precision: 15, scale: 2
    add_column :users, :maximum_investment, :decimal, precision: 15, scale: 2
    
    # Legal & Compliance (Step 5)
    add_column :users, :terms_of_service_accepted, :boolean, default: false
    add_column :users, :privacy_policy_accepted, :boolean, default: false
    add_column :users, :terms_accepted_at, :datetime
    add_column :users, :privacy_accepted_at, :datetime
    
    # Add indexes for better query performance
    add_index :users, :job_title
    add_index :users, :investment_frequency
    add_index :users, :accredited_investor
    add_index :users, :risk_tolerance
    add_index :users, :preferred_industries, using: 'gin'
    add_index :users, :preferred_investment_stages, using: 'gin'
  end
end
