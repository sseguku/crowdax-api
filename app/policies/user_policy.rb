class UserPolicy < ApplicationPolicy
  def index?
    admin? || backadmin?
  end

  def show?
    admin? || backadmin? || user == record
  end

  def create?
    true # Anyone can register
  end

  def update?
    admin? || backadmin? || user == record
  end

  def destroy?
    admin? || backadmin? || user == record
  end

  # Custom actions
  def profile?
    user.present?
  end

  def dashboard?
    user.present?
  end

  def update_profile?
    user == record
  end

  def admin_dashboard?
    admin? || backadmin?
  end

  def manage_users?
    admin? || backadmin?
  end

  def view_analytics?
    admin? || backadmin?
  end

  def export_data?
    admin? || backadmin?
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.backadmin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end 