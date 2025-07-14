class TransactionLogPolicy < ApplicationPolicy
  def index?
    user.admin? || user.backadmin?
  end

  def show?
    user.admin? || user.backadmin?
  end

  def create?
    # System can create logs, users cannot
    false
  end

  def update?
    # Logs should not be updated
    false
  end

  def destroy?
    # Logs should not be deleted
    false
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