module Spree
  BaseHelper.class_eval do
    # = ISSUE undefined local variable or method `display_price' for nil Class
    # == Source Override [1]
    # spree_price_books-ff06cba70d07/app/helpers/spree/base_helper_decorator.rb
    # TODO have tried disassociating store and price book but still the views are ruined
    # is +ensure_price_book+ causing a problem? See spree_price_books-ff06cba70d07/app/models/spree/price_decorator.rb
    # Have reloaded sample data, views display correct I think that Price associations may have been ruined. Keep an eye on this.
    def display_price(product_or_variant)
      # == > Modified conditional based on https://github.com/mlambie/spree-wholesale/blob/master/wholesale_extension.rb
      # if (spree_current_user && current_store.id && spree_current_user.has_spree_role?('user') && !product_or_variant.price.blank? )
      if current_store.id && spree_current_user && product_or_variant.price.present? # && spree_current_user.has_spree_role?('user')
        product_or_variant.price_in(current_currency,
                                    current_store.id,
                                    spree_current_user.try(:price_book_role_ids)
        ).display_price.to_html
      else
        # TODO match Store to domain name
        # product_or_variant.master.price_in(Spree::Config.currency, Spree::Store.default.id, Spree::Role.find_by!(name: 'user').id).display_price.to_html
        # product_or_variant.price_in(Spree::Config.currency, nil, nil).display_price.to_html
        # OR
        # If reverting to spree-c621abd94ead/core/app/models/spree/variant.rb:154
        # product_or_variant.price_in(Spree::Config.currency, nil, nil).display_price.to_html
        # OR
        # product_or_variant.master.default_price.display_price.to_html
        # OR
        product_or_variant.display_price.to_html
      end
    end
    # END Source Override [1]
  end
end
