module Spree
  module Api
    ProductsController.class_eval do
      # TODO we might prepare autocomplete terms from via API request instead
      def autocomplete
        @searcher = build_searcher(params.merge(autocomplete: true))
        @autocomplete_terms = @searcher.retrieve_products_autocomplete # .as_json

        if @autocomplete_terms
          expires_in 15.minutes, public: true
          headers['Surrogate-Control'] = "max-age=#{15.minutes}"
          # With RABL template or simply @autocomplete_terms.as_json
          respond_with(@autocomplete_terms, locals: { root_object: @autocomplete_terms })
        else
          head :no_content
        end
      end
    end
  end
end