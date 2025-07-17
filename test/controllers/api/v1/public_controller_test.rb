require 'test_helper'

class Api::V1::PublicControllerTest < ActionDispatch::IntegrationTest
  test "should get campaigns" do
    get api_v1_public_campaigns_url
    assert_response :success
  end

  test "should get statistics" do
    get api_v1_public_statistics_url
    assert_response :success
  end

  test "should get metadata" do
    get api_v1_public_metadata_url
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_includes json_response['data'], 'business_stages'
    assert_includes json_response['data'], 'legal_structures'
    assert_includes json_response['data'], 'industries'
    assert_includes json_response['data'], 'investment_frequencies'
    assert_includes json_response['data'], 'risk_tolerances'
    assert_includes json_response['data'], 'investment_stages'
  end

  test "should register entrepreneur successfully" do
    entrepreneur_params = {
      user: {
        email: 'entrepreneur@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        first_name: 'John',
        last_name: 'Doe',
        phone_number: '+1234567890',
        company_name: 'Tech Startup Inc',
        industry: 'technology',
        business_stage: 'early_traction',
        founded_date: '2023-01-01',
        website: 'https://techstartup.com',
        business_description: 'A revolutionary tech solution',
        problem_being_solved: 'Solving complex business problems',
        target_market: 'Small to medium businesses',
        competitive_advantage: 'Unique technology and approach',
        funding_amount_needed: 500000.00,
        funding_purpose: 'Product development and marketing',
        current_annual_revenue_min: 100000.00,
        current_annual_revenue_max: 500000.00,
        projected_annual_revenue_min: 1000000.00,
        projected_annual_revenue_max: 5000000.00,
        team_size_min: 5,
        team_size_max: 15,
        number_of_co_founders: 3,
        tin: '123456789',
        legal_structure: 'limited_liability_company'
      }
    }

    post api_v1_public_entrepreneur_registration_url, params: entrepreneur_params
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 'Entrepreneur registration successful. Please check your email to confirm your account.', json_response['status']['message']
    
    user = User.find_by(email: 'entrepreneur@example.com')
    assert_not_nil user
    assert_equal 'entrepreneur', user.role
    assert_equal 'John', user.first_name
    assert_equal 'Doe', user.last_name
    assert_equal '+1234567890', user.phone_number
    assert_equal 'Tech Startup Inc', user.company_name
  end

  test "should register investor successfully" do
    investor_params = {
      user: {
        email: 'investor@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        first_name: 'Jane',
        last_name: 'Smith',
        phone_number: '+1987654321',
        company_name: 'Investment Corp',
        job_title: 'Senior Investment Manager',
        industry: 'finance',
        years_of_experience_min: 5,
        years_of_experience_max: 10,
        typical_investment_amount_min: 10000.00,
        typical_investment_amount_max: 50000.00,
        investment_frequency: 'quarterly',
        preferred_industries: ['technology', 'healthcare'],
        preferred_investment_stages: ['growth_stage', 'scaling'],
        annual_income_min: 100000.00,
        annual_income_max: 200000.00,
        net_worth_min: 500000.00,
        net_worth_max: 1000000.00,
        accredited_investor: true,
        risk_tolerance: 'moderate',
        previous_investment_experience: 'I have invested in several startups over the past 5 years',
        investment_goals: 'To build a diverse portfolio of high-growth companies',
        minimum_investment: 5000.00,
        maximum_investment: 100000.00,
        terms_of_service_accepted: true,
        privacy_policy_accepted: true
      }
    }

    post api_v1_public_investor_registration_url, params: investor_params
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 'Investor registration successful. Please check your email to confirm your account.', json_response['status']['message']
    
    user = User.find_by(email: 'investor@example.com')
    assert_not_nil user
    assert_equal 'investor', user.role
    assert_equal 'Jane', user.first_name
    assert_equal 'Smith', user.last_name
    assert_equal '+1987654321', user.phone_number
    assert_equal 'Investment Corp', user.company_name
    assert_equal 'Senior Investment Manager', user.job_title
    assert_equal ['technology', 'healthcare'], user.preferred_industries
    assert_equal ['growth_stage', 'scaling'], user.preferred_investment_stages
    assert user.accredited_investor?
    assert user.terms_of_service_accepted?
    assert user.privacy_policy_accepted?
  end

  test "should fail entrepreneur registration with invalid data" do
    invalid_params = {
      user: {
        email: 'invalid-email',
        password: 'short',
        first_name: '',
        last_name: '',
        company_name: '',
        industry: 'invalid_industry',
        business_stage: 'invalid_stage',
        founded_date: '2025-01-01', # Future date
        funding_amount_needed: -1000,
        team_size_max: 5,
        team_size_min: 10 # Min greater than max
      }
    }

    post api_v1_public_entrepreneur_registration_url, params: invalid_params
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_equal 'Entrepreneur registration failed.', json_response['status']['message']
    assert_not_empty json_response['errors']
  end

  test "should fail investor registration with invalid data" do
    invalid_params = {
      user: {
        email: 'invalid-email',
        password: 'short',
        first_name: '',
        last_name: '',
        company_name: '',
        job_title: '',
        industry: 'invalid_industry',
        years_of_experience_max: 5,
        years_of_experience_min: 10, # Min greater than max
        typical_investment_amount_min: -1000,
        investment_frequency: 'invalid_frequency',
        preferred_industries: [], # Empty array
        preferred_investment_stages: [], # Empty array
        annual_income_max: 50000,
        annual_income_min: 100000, # Min greater than max
        net_worth_max: 100000,
        net_worth_min: 500000, # Min greater than max
        risk_tolerance: 'invalid_risk',
        minimum_investment: 10000,
        maximum_investment: 5000, # Max less than min
        terms_of_service_accepted: false,
        privacy_policy_accepted: false
      }
    }

    post api_v1_public_investor_registration_url, params: invalid_params
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_equal 'Investor registration failed.', json_response['status']['message']
    assert_not_empty json_response['errors']
  end

  test "should fail entrepreneur registration with duplicate email" do
    # Create existing user
    existing_user = users(:one)
    
    duplicate_params = {
      user: {
        email: existing_user.email,
        password: 'password123',
        password_confirmation: 'password123',
        first_name: 'John',
        last_name: 'Doe',
        phone_number: '+1234567890',
        company_name: 'Tech Startup Inc',
        industry: 'technology',
        business_stage: 'early_traction',
        founded_date: '2023-01-01',
        website: 'https://techstartup.com',
        business_description: 'A revolutionary tech solution',
        problem_being_solved: 'Solving complex business problems',
        target_market: 'Small to medium businesses',
        competitive_advantage: 'Unique technology and approach',
        funding_amount_needed: 500000.00,
        funding_purpose: 'Product development and marketing',
        current_annual_revenue_min: 100000.00,
        current_annual_revenue_max: 500000.00,
        projected_annual_revenue_min: 1000000.00,
        projected_annual_revenue_max: 5000000.00,
        team_size_min: 5,
        team_size_max: 15,
        number_of_co_founders: 3,
        tin: '123456789',
        legal_structure: 'limited_liability_company'
      }
    }

    post api_v1_public_entrepreneur_registration_url, params: duplicate_params
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response['errors'], 'Email has already been taken'
  end

  test "should fail investor registration with duplicate email" do
    # Create existing user
    existing_user = users(:one)
    
    duplicate_params = {
      user: {
        email: existing_user.email,
        password: 'password123',
        password_confirmation: 'password123',
        first_name: 'Jane',
        last_name: 'Smith',
        phone_number: '+1987654321',
        company_name: 'Investment Corp',
        job_title: 'Senior Investment Manager',
        industry: 'finance',
        years_of_experience_min: 5,
        years_of_experience_max: 10,
        typical_investment_amount_min: 10000.00,
        typical_investment_amount_max: 50000.00,
        investment_frequency: 'quarterly',
        preferred_industries: ['technology', 'healthcare'],
        preferred_investment_stages: ['growth_stage', 'scaling'],
        annual_income_min: 100000.00,
        annual_income_max: 200000.00,
        net_worth_min: 500000.00,
        net_worth_max: 1000000.00,
        accredited_investor: true,
        risk_tolerance: 'moderate',
        previous_investment_experience: 'I have invested in several startups over the past 5 years',
        investment_goals: 'To build a diverse portfolio of high-growth companies',
        minimum_investment: 5000.00,
        maximum_investment: 100000.00,
        terms_of_service_accepted: true,
        privacy_policy_accepted: true
      }
    }

    post api_v1_public_investor_registration_url, params: duplicate_params
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response['errors'], 'Email has already been taken'
  end
end 