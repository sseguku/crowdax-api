module RoleAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :authorize_role!
  end

  private

  def authorize_role!
    return unless defined?(self.class.required_roles)
    
    unless current_user && self.class.required_roles.any? { |role| current_user.send("#{role}?") }
      render json: {
        status: { 
          code: 403, 
          message: "Access denied. Required roles: #{self.class.required_roles.join(', ')}" 
        }
      }, status: :forbidden
    end
  end

  class_methods do
    def require_roles(*roles)
      self.required_roles = roles
    end

    def require_admin
      require_roles(:admin)
    end

    def require_backadmin
      require_roles(:backadmin)
    end

    def require_admin_or_backadmin
      require_roles(:admin, :backadmin)
    end

    def require_entrepreneur
      require_roles(:entrepreneur)
    end

    def require_investor
      require_roles(:investor)
    end

    def require_authenticated
      require_roles(:admin, :backadmin, :entrepreneur, :investor)
    end
  end
end 