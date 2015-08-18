module Spree
  class UserMailer < BaseMailer
    # Default from address set in application controller
    default from: "piktur.io@gmail.com" # current_store.mail_from_address ||= "sales@artscene.com.au"

    def mail(headers={}, &block)
      super if Spree::Config[:send_core_emails]
    end

    def mail_subject(subject)
      phrase = [] << current_store.name << subject
      phrase.join(' | ')
    end

    def reset_password_instructions(user, token, *args)
      @edit_password_reset_url =
        spree.edit_spree_user_password_url(
          reset_password_token: token,
          host: self.default_url_options[:host] ||= "http://as.dev:3000"
        )

      mail to: user.email,
           subject: mail_subject(
             I18n.t(:subject, scope: [:devise, :mailer, :reset_password_instructions]))
    end

    def confirmation_instructions(user, token, opts={})
      @confirmation_url =
        spree.spree_user_confirmation_url(
          confirmation_token: token,
          host: self.default_url_options[:host] ||= "http://as.dev:3000"
        )

      mail to: user.email,
           subject: mail_subject(
             I18n.t(:subject, scope: [:devise, :mailer, :confirmation_instructions]))
    end

    def follow_up(user)
      mail to: user.email,
           subject: "The Art Scene | We hope you enjoyed shopping with us, please come back"
    end
  end
end

