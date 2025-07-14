class Users::PasswordsController < Devise::PasswordsController
  respond_to :json
  skip_before_action :verify_authenticity_token

  # POST /users/password
  def create
    user = User.find_by(email: password_params[:email])
    
    if user
      user.send_reset_password_instructions
      render json: {
        status: { 
          code: 200, 
          message: 'Password reset instructions have been sent to your email.' 
        }
      }
    else
      render json: {
        status: { 
          code: 404, 
          message: 'Email not found.' 
        }
      }, status: :not_found
    end
  end

  # PUT /users/password
  def update
    user = User.reset_password_by_token(password_update_params)
    
    if user.errors.empty?
      user.unlock_access! if unlockable?(user)
      
      render json: {
        status: { 
          code: 200, 
          message: 'Password has been reset successfully.' 
        },
        data: {
          user: UserSerializer.new(user).serializable_hash[:data][:attributes]
        }
      }
    else
      render json: {
        status: { 
          code: 422, 
          message: 'Password reset failed.' 
        },
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:email)
  end

  def password_update_params
    params.require(:user).permit(:reset_password_token, :password, :password_confirmation)
  end

  def unlockable?(resource)
    resource.respond_to?(:unlock_access!) && resource.respond_to?(:lock_strategy_enabled?) && resource.lock_strategy_enabled?(:failed_attempts)
  end
end 