class KycPolicy < ApplicationPolicy
  def index?
    user.admin? || user.backadmin?
  end

  def show?
    user.admin? || user.backadmin? || record.user == user
  end

  def create?
    user.entrepreneur? && record.user == user
  end

  def update?
    user.admin? || user.backadmin? || (user.entrepreneur? && record.user == user)
  end

  def destroy?
    user.admin? || user.backadmin?
  end

  def approve?
    user.admin? || user.backadmin?
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.backadmin?
        scope.all
      elsif user.entrepreneur?
        scope.where(user: user)
      else
        scope.none
      end
    end
  end
end 