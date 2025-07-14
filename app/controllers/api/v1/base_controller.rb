class Api::V1::BaseController < ApplicationController
  include JwtAuthenticatable
  include RoleAuthorization
  
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user_from_token!
  
  respond_to :json
  
  private
  
  def render_success(data = nil, message = 'Success', status = :ok)
    render json: {
      status: { code: 200, message: message },
      data: data
    }, status: status
  end
  
  def render_error(message = 'Error', status = :unprocessable_entity)
    render json: {
      status: { code: status, message: message }
    }, status: status
  end
  
  def render_unauthorized(message = 'Unauthorized')
    render json: {
      status: { code: 401, message: message }
    }, status: :unauthorized
  end
  
  def render_forbidden(message = 'Forbidden')
    render json: {
      status: { code: 403, message: message }
    }, status: :forbidden
  end
end 