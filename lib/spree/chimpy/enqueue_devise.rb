# Mailer proxy to send devise emails in the background
# Note if difficulty performing tests, add below line to
# spec_helper.rb.
# Devise.mailer = Devise::Mailer
# This removes the backgrounding proxy during tests.
# https://github.com/mperham/sidekiq/wiki/Devise

module Spree::Chimpy
  class EnqueueDevise < Devise::Mailer
    def self.confirmation_instructions(record, token, opts = {})
      new(:confirmation_instructions, record, token, opts)
    end

    def self.reset_password_instructions(record, token, opts = {})
      new(:reset_password_instructions, record, token, opts)
    end

    def self.unlock_instructions(record, token, opts = {})
      new(:unlock_instructions, record, token, opts)
    end

    def initialize(method, record, token, opts = {})
      @method, @record, @token, @opts = method, record, token, opts
    end

    def deliver
      # You need to hardcode the class of the Devise mailer that you
      # actually want to use. The default is Devise::Mailer.
      Spree::UserMailer.delay.send(@method, @record, @token, @opts)
    end
  end
end
