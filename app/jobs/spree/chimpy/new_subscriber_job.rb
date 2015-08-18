class Spree::Chimpy::NewSubscriberJob < ActiveJob::Base
  queue_as :mailer

  def self.perform(user)
    user.subscribe
  end
end
