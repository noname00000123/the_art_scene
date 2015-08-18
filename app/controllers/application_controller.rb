class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # before_filter :mailer_set_url_options
  before_filter :default_url_options
  before_filter :spree_current_user
  before_filter :current_currency
  before_filter :add_current_store_id_to_params

  private

  # TODO How to set default_url_options according to environment and current_store?
  # http://stackoverflow.com/questions/3432712/action-mailer-default-url-options-and-request-host
  # NOTE: Non-request based invocations, ie. rake tasks, resque workers will fail
  # when set according to request.host_with_port
  def mailer_set_url_options
    # ActionMailer::Base.default_url_options = { host: TheArtScene::Config[:domain] }
    # Spree::UserMailer.default_url_options = { host: request.host_with_port }
    # ActionMailer::Base.config.default_url_options
  end


  def default_url_options
    domains = current_store.url.split(',') if current_store

    domain =
      if domains.present?
        domains.select do |url|
          if Rails.env.development? || Rails.env.test?
            url if url.include?("#{current_store.code}.dev")
          elsif Rails.env == 'staging'
            url if url.include?("#{current_store.code}.staging")
          elsif Rails.env.production?
            url unless url.include?("#{current_store.code}.")
          end
        end.first
      else
        request.host_with_port ||= 'http://localhost:3000'
      end

    # TODO VALIDATION REQUIRED, this is coming directly from a text field from an as yet
    # unvalidated form. Ensure we have a valid url. Meantime, lets just prepend the protocol
    Rails.application.routes.default_url_options = {host: "http://#{domain}"}
    ActionMailer::Base.default_url_options       = {host: "http://#{domain}"}

    # # TODO and set default mail from address per store
    # This is going into the url params, we probably dont want this to end up there
    # Send it back to the Mailer, we'll look at it again later
    # Spree::UserMailer.default from: current_store.mail_from_address ||=
    #   "sales@artscene.com.au"
  end

  def add_current_store_id_to_params
    # ==> lib/spree/core/controller_helpers/store.rb:17
    # @current_store ||= Spree::Store.current(request.env['SERVER_NAME'])

    # ==> app/helpers/spree_multi_domain/multi_domain_helpers_decorator.rb
    # params[:current_store_id] = Spree::Core::ControllerHelpers::Store.current_store.try(:id)
    params[:current_store_id] = current_store.id # || Spree::Store.current.try(:id)
      # Spree::Store.current.try(:id) ||
      #   Spree::Store.current(request.env['SERVER_NAME']).id
      #   # || 1
  end
end
