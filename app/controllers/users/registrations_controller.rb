class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  skip_before_action :verify_authenticity_token

  # POST /users
  def create
    build_resource(sign_up_params)
    
    # Set role to entrepreneur if not specified
    resource.role = 'entrepreneur' if resource.role.blank?
    
    resource.save
    yield resource if block_given?
    
    if resource.persisted?
      if resource.active_for_authentication?
        render json: {
          status: { 
            code: 200, 
            message: 'Account created successfully. Please check your email to confirm your account.' 
          },
          data: {
            user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
          }
        }
      else
        expire_data_after_sign_in!
        render json: {
          status: { 
            code: 200, 
            message: 'Account created successfully. Please check your email to confirm your account.' 
          },
          data: {
            user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
          }
        }
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      render json: {
        status: { 
          code: 422, 
          message: 'Account creation failed.' 
        },
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PUT /users
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    
    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
      
      render json: {
        status: { 
          code: 200, 
          message: 'Account updated successfully.' 
        },
        data: {
          user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
        }
      }
    else
      clean_up_passwords resource
      set_minimum_password_length
      render json: {
        status: { 
          code: 422, 
          message: 'Account update failed.' 
        },
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /users
  def destroy
    resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    yield resource if block_given?
    
    render json: {
      status: { 
        code: 200, 
        message: 'Account deleted successfully.' 
      }
    }
  end

  private

  def sign_up_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :role,
      # Entrepreneur-specific fields
      :first_name, :last_name, :phone_number, :company_name, :industry, :business_stage,
      :founded_date, :website, :business_description, :problem_being_solved,
      :target_market, :competitive_advantage, :funding_amount_needed,
      :funding_purpose, :current_annual_revenue_min, :current_annual_revenue_max,
      :projected_annual_revenue_min, :projected_annual_revenue_max,
      :team_size_min, :team_size_max, :number_of_co_founders, :tin, :legal_structure,
      # Investor-specific fields
      :job_title, :years_of_experience_min, :years_of_experience_max,
      :typical_investment_amount_min, :typical_investment_amount_max, :investment_frequency,
      :preferred_industries, :preferred_investment_stages, :annual_income_min, :annual_income_max,
      :net_worth_min, :net_worth_max, :accredited_investor, :risk_tolerance,
      :previous_investment_experience, :investment_goals, :minimum_investment, :maximum_investment,
      :terms_of_service_accepted, :privacy_policy_accepted
    )
  end

  def account_update_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :current_password, :role,
      # Entrepreneur-specific fields
      :first_name, :last_name, :phone_number, :company_name, :industry, :business_stage,
      :founded_date, :website, :business_description, :problem_being_solved,
      :target_market, :competitive_advantage, :funding_amount_needed,
      :funding_purpose, :current_annual_revenue_min, :current_annual_revenue_max,
      :projected_annual_revenue_min, :projected_annual_revenue_max,
      :team_size_min, :team_size_max, :number_of_co_founders, :tin, :legal_structure,
      # Investor-specific fields
      :job_title, :years_of_experience_min, :years_of_experience_max,
      :typical_investment_amount_min, :typical_investment_amount_max, :investment_frequency,
      :preferred_industries, :preferred_investment_stages, :annual_income_min, :annual_income_max,
      :net_worth_min, :net_worth_max, :accredited_investor, :risk_tolerance,
      :previous_investment_experience, :investment_goals, :minimum_investment, :maximum_investment,
      :terms_of_service_accepted, :privacy_policy_accepted
    )
  end

  def update_resource(resource, params)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end
    resource.update_without_password(params)
  end
end 