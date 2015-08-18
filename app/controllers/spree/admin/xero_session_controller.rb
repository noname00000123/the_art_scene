module Spree
  module Admin
    class XeroSessionController < Spree::Admin::BaseController
      before_filter :get_xero_client

      def contacts
        render json: @client.Contact.all.to_json
      end

      def queue
        ExportNewCustomersJob.perform_later('/tmp/my_file.csv')
      end

      private

      def get_xero_client
        @client = Xeroizer::PrivateApplication.new(
            ENV['DEMO_XERO_CONSUMER_KEY'],
            ENV['DEMO_XERO_CONSUMER_SECRET'],
            "#{Rails.root}/xero/demo/privatekey.pem"
        )

        # Add AccessToken if authorised previously.
        if session[:xero_auth]
          @client.authorize_from_access(
              session[:xero_auth][:access_token],
              session[:xero_auth][:access_key] )
        end
      end
    end
  end
end
