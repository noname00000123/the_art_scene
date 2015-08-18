class Spree::Chimpy::SendFollowUpJob < ActiveJob::Base
  queue_as :mailer

  def self.perform(user)
    Spree::UserMailer.follow_up(user).deliver_later
    # Spree::UserMailer.delay_for(5.days).follow_up(user)
  end
end