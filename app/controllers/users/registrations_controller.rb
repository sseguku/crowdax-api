class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  skip_before_action :verify_authenticity_token

  # POST /users
  def create
    build_resource(sign_up_params)
    
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
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end

  def account_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :role)
  end

  def update_resource(resource, params)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end
    resource.update_without_password(params)
  end
end 