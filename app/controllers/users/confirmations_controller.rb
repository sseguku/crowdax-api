class Users::ConfirmationsController < Devise::ConfirmationsController
  respond_to :json
  skip_before_action :verify_authenticity_token

  # GET /users/confirmation
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    
    if resource.errors.empty?
      render json: {
        status: { 
          code: 200, 
          message: 'Email confirmed successfully.' 
        },
        data: {
          user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
        }
      }
    else
      render json: {
        status: { 
          code: 422, 
          message: 'Email confirmation failed.' 
        },
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # POST /users/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    
    if successfully_sent?(resource)
      render json: {
        status: { 
          code: 200, 
          message: 'Confirmation instructions have been sent to your email.' 
        }
      }
    else
      render json: {
        status: { 
          code: 422, 
          message: 'Failed to send confirmation instructions.' 
        },
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def resource_params
    params.require(:user).permit(:email)
  end
end 