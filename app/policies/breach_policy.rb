class BreachPolicy < ApplicationPolicy
  def index?
    user.admin? || user.backadmin?
  end

  def show?
    user.admin? || user.backadmin?
  end

  def create?
    user.admin? || user.backadmin?
  end

  def update?
    user.admin? || user.backadmin?
  end

  def destroy?
    user.admin? || user.backadmin?
  end

  def resolve?
    user.admin? || user.backadmin?
  end

  def mark_false_positive?
    user.admin? || user.backadmin?
  end

  def summary?
    user.admin? || user.backadmin?
  end

  def test_breach_detection?
    user.admin? || user.backadmin?
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.backadmin?
        scope.all
      else
        scope.none
      end
    end
  end
end 