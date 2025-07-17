class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include JwtAuthenticatable
  
  # Handle Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  private
  
  def user_not_authorized
    render json: {
      status: { 
        code: 403, 
        message: 'You are not authorized to perform this action.' 
      }
    }, status: :forbidden
  end
end
