module JwtAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user_from_token!
  end

  private

  def authenticate_user!
    authenticate_user_from_token!
  end

  def authenticate_user_from_token!
    unless current_user
      render json: {
        status: { 
          code: 401, 
          message: 'Authentication required. Please provide a valid token.' 
        }
      }, status: :unauthorized
    end
  end

  def current_user
    @current_user ||= current_user_from_token
  end

  def current_user_from_token
    return nil unless request.headers['Authorization']
    
    token = request.headers['Authorization'].split(' ').last
    return nil if token.blank?
    
    begin
      decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
      user_id = decoded_token.first['sub']
      User.find(user_id)
    rescue JWT::DecodeError, JWT::ExpiredSignature, ActiveRecord::RecordNotFound
      nil
    end
  end
end 