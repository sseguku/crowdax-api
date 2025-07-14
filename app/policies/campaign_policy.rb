class CampaignPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && (record.user_id == user.id || user.admin? || user.backadmin? || record.campaign_status == 'approved' || record.campaign_status == 'funded')
  end

  def create?
    user.present? && user.can_create_campaign?
  end

  def update?
    user.present? && (record.user_id == user.id || user.admin? || user.backadmin?)
  end

  def destroy?
    user.present? && (record.user_id == user.id || user.admin? || user.backadmin?)
  end

  def approve?
    user.present? && (user.admin? || user.backadmin?)
  end

  def submit?
    user.present? && record.user_id == user.id && record.draft?
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.backadmin?
        scope.all
      elsif user.entrepreneur?
        scope.where(user: user)
      else
        scope.where(campaign_status: ['approved', 'funded'])
      end
    end
  end
end 