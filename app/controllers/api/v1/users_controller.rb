class Api::V1::UsersController < Api::V1::BaseController
  # GET /api/v1/users/profile
  def profile
    authorize current_user, :profile?
    render_success(
      UserSerializer.new(current_user).serializable_hash[:data][:attributes],
      'User profile retrieved successfully'
    )
  end

  # PUT /api/v1/users/profile
  def update_profile
    authorize current_user, :update_profile?
    if current_user.update(user_params)
      render_success(
        UserSerializer.new(current_user).serializable_hash[:data][:attributes],
        'Profile updated successfully'
      )
    else
      render_error(current_user.errors.full_messages.join(', '))
    end
  end

  # GET /api/v1/users/dashboard
  def dashboard
    authorize current_user, :dashboard?
    # Example of a protected endpoint that requires authentication
    dashboard_data = {
      user: UserSerializer.new(current_user).serializable_hash[:data][:attributes],
      stats: {
        total_logins: current_user.sign_in_count || 0,
        last_sign_in: current_user.last_sign_in_at,
        role: current_user.role
      }
    }
    
    render_success(dashboard_data, 'Dashboard data retrieved successfully')
  end

  # GET /api/v1/users/admin_dashboard (admin only)
  def admin_dashboard
    authorize current_user, :admin_dashboard?
    admin_data = {
      total_users: User.count,
      users_by_role: User.group(:role).count,
      recent_signups: User.order(created_at: :desc).limit(10).map { |u| UserSerializer.new(u).serializable_hash[:data][:attributes] }
    }
    
    render_success(admin_data, 'Admin dashboard data retrieved successfully')
  end

  # GET /api/v1/users/analytics (admin/backadmin only)
  def analytics
    authorize current_user, :view_analytics?
    analytics_data = {
      user_growth: User.group("DATE(created_at)").count,
      role_distribution: User.group(:role).count,
      active_users: User.where('last_sign_in_at > ?', 30.days.ago).count
    }
    
    render_success(analytics_data, 'Analytics data retrieved successfully')
  end

  private

  def user_params
    params.require(:user).permit(:email, :role)
  end
end 