class Spree::Chimpy::SendOrderCancellationEmailJob < ActiveJob::Base
  queue_as :mailer

  def self.perform(order, resend)
    Spree::OrderMailer.cancel_email(order, resend).deliver_now
    # Spree::UserMailer.delay_for(5.days).follow_up(user)
  end
end