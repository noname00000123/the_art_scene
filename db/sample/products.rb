# Spree::Sample.load_sample("tax_categories")
# Spree::Sample.load_sample("shipping_categories")
#
# clothing = Spree::TaxCategory.find_by_name!("Clothing")
# shipping_category = Spree::ShippingCategory.find_by_name!("Default")
#
# default_attrs = {
#     :description => Faker::Lorem.paragraph,
#     :available_on => Time.zone.now
# }
#
# products = [
#     {
#         :name => "Ruby on Rails Tote",
#         :tax_category => clothing,
#         :shipping_category => shipping_category,
#         :price => 15.99,
#     },
#     {
#         :name => "Ruby on Rails Bag",
#         :tax_category => clothing,
#         :shipping_category => shipping_category,
#         :price => 22.99,
#     },
#     {
#         :name => "Ruby on Rails Baseball Jersey",
#         :tax_category => clothing,
#         :shipping_category => shipping_category,
#         :price => 19.99,
#     },
#     {
#         :name => "Ruby on Rails Jr. Spaghetti",
#         :tax_category => clothing,
#         :shipping_category => shipping_category,
#         :price => 19.99,
#     },
#     {
#         :name => "Ruby on Rails Ringer T-Shirt",
#         :shipping_category => shipping_category,
#         :tax_category => clothing,
#         :price => 19.99,
#     },
#     {
#         :name => "Ruby Baseball Jersey",
#         :tax_category => clothing,
#         :shipping_category => shipping_category,
#         :price => 19.99,
#     },
#     {
#         :name => "Apache Baseball Jersey",
#         :tax_category => clothing,
#         :shipping_category => shipping_category,
#         :price => 19.99,
#     },
#     {
#         :name => "Spree Baseball Jersey",
#         :tax_category => clothing,
#         :shipping_category => shipping_category,
#         :price => 19.99,
#     },
#     {
#         :name => "Spree Jr. Spaghetti",
#         :tax_category => clothing,
#         :shipping_category => shipping_category,
#         :price => 19.99,
#     },
#     {
#         :name => "Spree Ringer T-Shirt",
#         :tax_category => clothing,
#         :shipping_category => shipping_category,
#         :price => 19.99,
#     },
#     {
#         :name => "Spree Tote",
#         :tax_category => clothing,
#         :shipping_category => shipping_category,
#         :price => 15.99,
#     },
#     {
#         :name => "Spree Bag",
#         :tax_category => clothing,
#         :shipping_category => shipping_category,
#         :price => 22.99,
#     },
#     {
#         :name => "Ruby on Rails Mug",
#         :shipping_category => shipping_category,
#         :price => 13.99,
#     },
#     {
#         :name => "Ruby on Rails Stein",
#         :shipping_category => shipping_category,
#         :price => 16.99,
#     },
#     {
#         :name => "Spree Stein",
#         :shipping_category => shipping_category,
#         :price => 16.99,
#     },
#     {
#         :name => "Spree Mug",
#         :shipping_category => shipping_category,
#         :price => 13.99,
#     }
# ]
#
# Money::Bank::GoogleCurrency.ttl_in_seconds = 86400
# # set default bank to instance of GoogleCurrency
# Money.default_bank = Money::Bank::GoogleCurrency.new
# Money::Currency.all.each do |currency|
#   # Limit to only major currencies, which have priority below 100.
#   next if currency.priority >= 100
#   begin
#     rate = Money.default_bank.get_rate(Spree::CurrencyRate.default.currency, currency.iso_code)
#     if cr = Spree::CurrencyRate.find_or_create_by(
#         base_currency: Spree::CurrencyRate.default.currency,
#         currency: currency.iso_code,
#         default: (Spree::Config[:currency] == currency.iso_code)
#     )
#       cr.update_attribute :exchange_rate, rate
#     end
#   rescue Money::Bank::UnknownRate # Google doesn't track this currency.
#   rescue Money::Bank::GoogleCurrencyFetchError => ex
#     puts currency.inspect
#     puts ex.message
#     puts ex.backtrace
#   end
# end
#
# price_book = Spree::PriceBook.find_or_create_by!(
#     name:         'Default',
#     currency:     Spree::Config.currency,
#     active_from:  (1.day.ago).strftime('%Y/%m/%d'), # Time.parse(item[:active_from].to_s) || 1.day.ago,
#     active_to:    (1.year.from_now).strftime('%Y/%m/%d'), # Time.parse(item[:active_to].to_s) || 1.year.from_now,
#     default:      true, # item[:default] == 1 ? true : false,
#     price_adjustment_factor: nil, # item[:price_adjustment_factor] || 1,
#     priority:     0,
#     discount:     false, # item[:discount] == 1 ? true : false,
#     role:         Spree::Role.find_by!(name: 'user'), # Spree::Role.find_by!(name: item[:role]) && Spree::Role.find_by!(name: 'admin'),
#     parent:       nil
# )
#
# Spree::StorePriceBook.create!(
#     price_book: price_book,
#     store: Spree::Store.find_by!(default: true),
#     priority: 0
# )
#
# # TODO load currency only one currency should be created
# products.each do |product_attrs|
#   Spree::Config[:currency] = "USD"
#
#   default_shipping_category = Spree::ShippingCategory.find_by_name!("Default")
#   product = Spree::Product.create!(default_attrs.merge(product_attrs))
#   product.shipping_category = default_shipping_category
#   product.stores << Spree::Store.find_by!(default: true)
#   product.save!
#
#   price_book.prices << Spree::Price.find_or_create_by!(
#       variant_id: product.master.id,
#       price_book_id: price_book,
#       amount: product.master.price,
#       currency: product.cost_currency
#   )
#   price_book.save!
# end
#
