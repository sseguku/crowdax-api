class AdminMailer < ApplicationMailer
  def breach_notification(breach)
    @breach = breach
    @user = breach.user
    @severity = breach.severity
    @breach_type = breach.breach_type
    
    # Get admin users
    admin_users = User.where(role: ['admin', 'backadmin'])
    
    if admin_users.any?
      mail(
        to: admin_users.pluck(:email),
        subject: "🚨 SECURITY BREACH ALERT: #{breach.severity.upcase} - #{breach.breach_type.humanize}"
      )
    end
  end

  def breach_summary(breaches)
    @breaches = breaches
    @total_breaches = breaches.count
    @critical_breaches = breaches.critical.count
    @open_breaches = breaches.open.count
    
    admin_users = User.where(role: ['admin', 'backadmin'])
    
    if admin_users.any?
      mail(
        to: admin_users.pluck(:email),
        subject: "📊 Security Breach Summary: #{@total_breaches} incidents (#{@critical_breaches} critical)"
      )
    end
  end
end 