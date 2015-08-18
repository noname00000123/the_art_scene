# == Source Override [1]
# spree-0959c62971c1/core/app/models/spree/order.rb
module Spree
  Order.class_eval do
    # == Source Override [2]
    # spree-multi-domain-3734b6b678ba/app/models/spree/order_decorator.rb
    belongs_to :store, class_name: 'Spree::Store'
    # End Source Override [2]

    # Finalizes an in progress order after checkout is complete.
    # Called after transition to complete state when payments will have been processed
    def finalize!
      # lock all adjustments (coupon promotions, etc.)
      all_adjustments.each{|a| a.close}

      # update payment and shipment(s) states, and save
      updater.update_payment_state
      shipments.each do |shipment|
        shipment.update!(self)
        shipment.finalize!
      end

      updater.update_shipment_state
      save!
      updater.run_hooks

      touch :completed_at

      deliver_order_confirmation_email unless confirmation_delivered?

      consider_risk
    end

    def deliver_order_confirmation_email
      # TODO made a new job
      OrderMailer.confirm_email(id).deliver_later
      update_column(:confirmation_delivered, true)
    end

    private

    def after_cancel
      shipments.each { |shipment| shipment.cancel! }
      payments.completed.each { |payment| payment.cancel! }
      send_cancel_email
      self.update!
    end

    def send_cancel_email
      OrderMailer.cancel_email(id).deliver_later
    end
  end
end
