class Users::SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_authenticity_token, only: [:create, :destroy]

  # POST /users/sign_in
  def create
    user = User.find_by(email: sign_in_params[:email])
    
    if user&.valid_password?(sign_in_params[:password])
      sign_in(user)
      render json: {
        status: { code: 200, message: 'Logged in successfully.' },
        data: {
          user: UserSerializer.new(user).serializable_hash[:data][:attributes],
          token: request.env['warden-jwt_auth.token']
        }
      }
    else
      render json: {
        status: { 
          code: 401, 
          message: 'Invalid email or password.' 
        }
      }, status: :unauthorized
    end
  end

  # DELETE /users/sign_out
  def destroy
    if current_user
      sign_out(current_user)
      render json: {
        status: { 
          code: 200, 
          message: "Logged out successfully." 
        }
      }
    else
      render json: {
        status: { 
          code: 401, 
          message: "Couldn't find an active session." 
        }
      }, status: :unauthorized
    end
  end

  # GET /users/current_user
  def current_user_info
    if current_user
      render json: {
        status: { code: 200, message: 'User authenticated.' },
        data: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: { 
          code: 401, 
          message: 'No active session found.' 
        }
      }, status: :unauthorized
    end
  end

  # POST /users/refresh_token
  def refresh_token
    if current_user
      # Generate a new token
      new_token = request.env['warden-jwt_auth.token']
      render json: {
        status: { code: 200, message: 'Token refreshed successfully.' },
        data: {
          user: UserSerializer.new(current_user).serializable_hash[:data][:attributes],
          token: new_token
        }
      }
    else
      render json: {
        status: { 
          code: 401, 
          message: 'Invalid or expired token.' 
        }
      }, status: :unauthorized
    end
  end

  private

  def sign_in_params
    params.require(:user).permit(:email, :password)
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'Logged in successfully.' },
        data: {
          user: UserSerializer.new(resource).serializable_hash[:data][:attributes],
          token: request.env['warden-jwt_auth.token']
        }
      }
    else
      render json: {
        status: { 
          code: 422, 
          message: "Log in failed. #{resource.errors.full_messages.to_sentence}" 
        }
      }, status: :unprocessable_entity
    end
  end

  def respond_to_on_destroy
    if current_user
      render json: {
        status: { 
          code: 200, 
          message: "Logged out successfully." 
        }
      }
    else
      render json: {
        status: { 
          code: 401, 
          message: "Couldn't find an active session." 
        }
      }, status: :unauthorized
    end
  end
end 