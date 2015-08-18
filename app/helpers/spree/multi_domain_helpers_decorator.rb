module Spree
  module MultiDomainHelpers
    # == Source Override [1] spree-multi-domain-3734b6b678ba/lib/spree_multi_domain/multi_domain_helpers.rb:6
    def self.included(receiver)
      receiver.send :helper, 'spree/products'
      receiver.send :helper, 'spree/taxons'

      receiver.send :before_filter, :add_current_store_id_to_params
      receiver.send :helper_method, :current_store
      receiver.send :helper_method, :current_tracker
    end

    def current_tracker
      @current_tracker ||= Spree::Tracker.current(request.env['SERVER_NAME'])
    end

    # Reference join table spree_store_taxonomies rather than spree_taxonomies
    def get_taxonomies
      @taxonomies ||=
        current_store.present? ? current_store.taxonomies : Spree::Taxonomy.all
      @taxonomies = @taxonomies.includes(:root => :children)
      @taxonomies
    end

    def add_current_store_id_to_params
      # params[:current_store_id] = Spree::Core::ControllerHelpers::Store.current_store.try(:id)
      params[:current_store_id] = Spree::Store.current.try(:id) || 1
    end
    # End Source Override [1]
  end
end

DeviseController.send :include, Spree::MultiDomainHelpers

