if Spree.user_class
  Spree.user_class.class_eval do
    devise :async

    after_create :enqueue_subscription
    after_create :schedule_follow_up

    has_many :interest_groups, class_name: 'Spree::InterestGroup'
    has_many :interests, class_name: 'Spree::Interest', through: :interest_groups

    # Override devise method so that mail is enqueued with ActiveJob
    def send_devise_notification(notification, *args)
      Spree::UserMailer.send(notification, self, *args).deliver_later
    end

    def enqueue_subscription
      Spree::Chimpy::NewSubscriberJob.perform_later(self)
    end

    def schedule_follow_up
      Spree::Chimpy::SendFollowUpJob.perform_later(self)
    end
  end
end
