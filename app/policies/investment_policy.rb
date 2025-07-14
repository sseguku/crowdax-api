class InvestmentPolicy < ApplicationPolicy
  def index?
    user.admin? || user.backadmin?
  end

  def show?
    user.admin? || user.backadmin? || record.user == user || record.campaign.user == user
  end

  def create?
    user.investor? && record.user == user
  end

  def update?
    user.admin? || user.backadmin? || (user.investor? && record.user == user)
  end

  def destroy?
    user.admin? || user.backadmin?
  end

  def confirm?
    user.admin? || user.backadmin?
  end

  def cancel?
    user.admin? || user.backadmin? || (user.investor? && record.user == user && record.pending?)
  end

  def refund?
    user.admin? || user.backadmin?
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.backadmin?
        scope.all
      elsif user.investor?
        scope.where(user: user)
      elsif user.entrepreneur?
        scope.joins(:campaign).where(campaigns: { user: user })
      else
        scope.none
      end
    end
  end
end 