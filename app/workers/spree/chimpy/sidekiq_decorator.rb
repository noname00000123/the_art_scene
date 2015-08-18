Spree::Chimpy::Workers::Sidekiq.class_eval do
  delegate :log, to: Spree::Chimpy

  if defined?(::Sidekiq)
    include ::Sidekiq::Worker

    sidekiq_options queue: :mailer,
                    retry: 3,
                    backtrace: true
  end

  def perform(payload)
    Spree::Chimpy.perform(payload.with_indifferent_access)

    rescue Excon::Errors::Timeout, Excon::Errors::SocketError
      log "Mailchimp connection timeout reached, closing"
  end
end
