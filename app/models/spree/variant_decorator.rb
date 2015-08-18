# == Source Override [1]
# See spree_price_books-ff06cba70d07/app/models/spree/variant_decorator.rb
Spree::Variant.class_eval do
  def display_list_price(currency = Spree::Config[:currency], store_id = Spree::Store.default.id, role_ids = nil)
    lp = list_price_in(currency, store_id)
    raise RuntimeError, "No available price for Variant #{id} with #{currency} currency in store #{store_id}." unless lp
    Spree::Money.new lp.amount, currency: lp.currency
  end

  def list_price_in(currency = Spree::Config[:currency], store_id = Spree::Store.default.id, role_ids = nil)
    if store_id
      prices.list.by_currency(currency).by_store(store_id).by_role(role_ids).first
    else
      prices.list.by_currency(currency).by_role(role_ids).first
    end
  end

  # Ensure correct prices for store
  def price_in(currency = Spree::Config[:currency], store_id = Spree::Store.current || Spree::Store.default.id, role_ids = nil)
    # Include fallback as per spree-c621abd94ead/core/app/models/spree/variant.rb:154
    # def price_in(currency)
    #   prices.detect { |price| price.currency == currency } || Spree::Price.new(variant_id: id, currency: currency)
    # end

    # if store_id
    prices.detect { |price| price.currency == currency } || Spree::Price.new(variant_id: id, currency: currency)
    prices.by_currency(currency).by_store(store_id).first # .by_role(role_ids).first
    # else
    # prices.detect { |price| price.currency == currency } || Spree::Price.new(variant_id: id, currency: currency)
    # prices.by_currency(currency) # .by_role(role_ids).first
    # end
  end
end
# End Source Override [1]