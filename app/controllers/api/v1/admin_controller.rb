class Api::V1::AdminController < Api::V1::BaseController
  require_admin_or_backadmin

  # GET /api/v1/admin/users
  def users
    users = policy_scope(User)
    render_success(
      users.map { |u| UserSerializer.new(u).serializable_hash[:data][:attributes] },
      'Users list retrieved successfully'
    )
  end

  # GET /api/v1/admin/users/:id
  def show_user
    user = User.find(params[:id])
    authorize user, :show?
    render_success(
      UserSerializer.new(user).serializable_hash[:data][:attributes],
      'User details retrieved successfully'
    )
  end

  # PUT /api/v1/admin/users/:id
  def update_user
    user = User.find(params[:id])
    authorize user, :update?
    if user.update(admin_user_params)
      render_success(
        UserSerializer.new(user).serializable_hash[:data][:attributes],
        'User updated successfully'
      )
    else
      render_error(user.errors.full_messages.join(', '))
    end
  end

  # DELETE /api/v1/admin/users/:id
  def destroy_user
    user = User.find(params[:id])
    authorize user, :destroy?
    user.destroy
    render_success(nil, 'User deleted successfully')
  end

  # GET /api/v1/admin/export_users
  def export_users
    authorize current_user, :export_data?
    users_data = User.all.map { |u| UserSerializer.new(u).serializable_hash[:data][:attributes] }
    
    render_success(
      {
        total_count: users_data.count,
        users: users_data,
        exported_at: Time.current.iso8601
      },
      'Users data exported successfully'
    )
  end

  private

  def admin_user_params
    params.require(:user).permit(:email, :role, :confirmed_at)
  end
end 