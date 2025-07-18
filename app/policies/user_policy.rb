class UserPolicy < ApplicationPolicy
  def index?
    user.admin? || user.backadmin?
  end

  def show?
    user.admin? || user.backadmin? || record == user
  end

  def create?
    # Anyone can register
    true
  end

  def update?
    user.admin? || user.backadmin? || record == user
  end

  def destroy?
    user.admin? || user.backadmin?
  end

  def update_profile?
    record == user
  end

  def dashboard?
    user.present?
  end

  def admin_dashboard?
    user.admin? || user.backadmin?
  end

  def analytics?
    user.admin? || user.backadmin?
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