class NotificationMailer < ActionMailer::Base
  def mail_subject(subject)
    subject = []
    subject << Spree::Store.current.name
    subject.join(' | ')
  end

  def task_complete(user, token, *args)
    mail to: user.email,
         from: %{'The Art Scene Online Admin' <noreply@artscene.com>},
         subject: 'Task Complete'
  end
end

