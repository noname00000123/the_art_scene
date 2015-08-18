@au    = Spree::Country.find_by(iso: 'AU')
us    = Spree::Country.find_by(iso: 'US')
nsw   = Spree::State.find_by(country: @au, abbr: 'NSW')
tas   = Spree::State.find_by(country: @au, abbr: 'TAS')
ny    = Spree::State.find_by(country: us, abbr: 'NY')

@invoice_range = Range.new(2000, 3000).entries
@gateway_range = Range.new(2000, 3000).entries

@admin = Spree::User.admin.first
@users = []
@orders = []

@interests = ['Painting', 'Drawing', 'Sculpture', 'Design & Architecture', 'Education']
@interests.collect! {|i| Spree::Interest.find_or_create_by!(interest: i)}

@expertise = ['Enthusiast', 'Professional']

def date_rand(from = 0.0, to = Time.now)
  Time.at(from + rand * (to.to_f - from.to_f))
end

def metro
  sydney = [1000..1404, 1411..1920, 2000..2249, 2555..2574, 2740..2786]
  sydney.collect! {|i| Range === i ? i.entries : i}.flatten!
  sydney.sample
end

# Hack the current method so we're able to return a gateway without a RAILS_ENV
# Spree::Gateway.class_eval do
#   def self.current
#     Spree::Gateway::Bogus.new
#
    # Spree::Gateway::BraintreeGateway.create!(
    #   name: 'Braintree',
    #   description: 'Secure Credit Card Payments with Braintree',
    #   active: true,
    #   created_at: Time.zone.now,
    #   display_on: '', #all
    #   auto_capture: Spree::Config.auto_capture,
    #   preferences: {
    #     test_mode: true,
    #     server:               :development,
    #     environment:          :sandbox,
    #     merchant_id:          ENV['BRAINTREE_MERCHANT_ID'],
    #     merchant_account_id:  ENV['BRAINTREE_MERCHANT_ACCOUNT_ID'],
    #     public_key:           ENV['BRAINTREE_PUBLIC_KEY'],
    #     private_key:          ENV['BRAINTREE_PRIVATE_KEY'],
    #     client_side_encryption_key: ENV['BRAINTREE_CSE_KEY'],
    #     use_client_side_encryption: true
    #   }
    # )
#
#     Spree::Gateway::.new(
#         name: 'Braintree',
#         description: 'Secure Credit Card Payments with Braintree',
#         active: true,
#         created_at: Time.zone.now,
#         display_on: '', #all
#         auto_capture: Spree::Config.auto_capture,
#         server: 'development',
#         preferences: {
#             environment:          :sandbox,
#             merchant_id:          ENV['BRAINTREE_MERCHANT_ID'],
#             merchant_account_id:  ENV['BRAINTREE_MERCHANT_ACCOUNT_ID'],
#             public_key:           ENV['BRAINTREE_PUBLIC_KEY'],
#             private_key:          ENV['BRAINTREE_PRIVATE_KEY'],
#             client_side_encryption_key: ENV['BRAINTREE_CSE_KEY']
#         }
#     )
#
#   end
# end

# This table was previously called spree_creditcards, and older migrations
# reference it as such. Make it explicit here that this table has been renamed.
Spree::CreditCard.table_name = 'spree_credit_cards'

def creditcard(fname, sname, profile_id)
  Spree::CreditCard.create(
    cc_type: 'visa',
    month: 12,
    year: 2.years.from_now.year,
    last_digits: '1111',
    name: [fname, sname].join(' '),
    gateway_customer_profile_id: "BGS#{profile_id}"
  )
end

# ===========================================================================
# == Create Users taking care not to upset Devise
# ===========================================================================
# TODO Sample Postcodes
# TwitterCldr::Shared::PostalCodes.for_territory(:au).sample[0](2000)
def locality(zone)
  l = {phone: Faker::PhoneNumberAU.international_mobile_phone_number}

  case zone
    when 'inner_states_metro'
      state = Spree::State.find_by!(country: @au.id, abbr: %w(NSW QLD SA VIC).sample)

      l.merge!({
        city: Faker::AddressAU.city,
        state: state,
        state_name: state.name,
        zipcode: metro,
        country: @au
      })

    when 'inner_states'
      state = Spree::State.find_by!(country: @au.id, abbr: %w(NSW QLD SA VIC).sample)

      l.merge!({
           city: Faker::AddressAU.city,
           state: state,
           state_name: state.name,
           # Return postcode sample as string
           zipcode: TwitterCldr::Shared::PostalCodes.for_territory(:au).sample[0],
           country: @au
       })

    when 'outer_states'
      state = Spree::State.find_by!(country: @au.id, abbr: %w(WA TAS NT ACT).sample)

      l.merge!({
        city: Faker::AddressAU.city,
        state: state,
        state_name: state.name,
        # Return postcode sample as string
        zipcode: TwitterCldr::Shared::PostalCodes.for_territory(:au).sample[0],
        country: @au
      })

    when 'outer_states'
      state = Spree::State.find_by!(country: @au.id, abbr: %w(WA TAS NT ACT).sample)

      l.merge!({
        city: Faker::AddressAU.city,
        state: state,
        state_name: state.name,
        # Faker::AddressAU.postcode(state.abbr)
        zipcode: TwitterCldr::Shared::PostalCodes.for_territory(:au).sample[0],
        country: @au
      })

    when 'national'
      state = Faker::AddressAU.state_abbr

      l.merge!({
        city: Faker::AddressAU.city,
        state: Spree::State.find_by!(country: @au.id, abbr: state),
        state_name: Spree::State.find_by!(country: @au.id, abbr: state).name,
        zipcode: TwitterCldr::Shared::PostalCodes.for_territory(:au).sample[0],
        country: @au
      })

    when 'international'
      country = Spree::Country.find_by!(iso: 'US')
      state = Spree::State.find_by(name: 'New York')

      l = {
        city: Faker::AddressUS.city,
        state: state,
        state_name: state.name,
        # Ensure valid postcode for region
        zipcode: TwitterCldr::Shared::PostalCodes.for_territory(:us).sample[0], # Faker::AddressUS.zip_code,
        country: country,
        phone: Faker::PhoneNumber.short_phone_number
      }
  end

  l
end

# ===========================================================================
# == Create users with
# - addresses matching defined zones, and
# - a credit card in their name
# ===========================================================================
def random_user(options={})
  default_options = {
    email: nil,
    zone: 'inner_states_metro',
    role: 'customer_retail',
    use_billing: true
  }

  opts = options.reverse_merge(default_options)

  fname = Faker::Name.first_name
  lname = Faker::Name.last_name

  address = Spree::Address.find_or_create_by!(
    {
      firstname: fname,
      lastname: lname,
      address1: Faker::Address.street_address,
      address2: Faker::Address.secondary_address
    }.merge!(locality(opts[:zone]))
  )

  time = date_rand(Time.parse('01/07/2014'), Time.parse('30/06/2015'))

  # new rather than create
  u = Spree::User.new(
    firstname:    fname,
    lastname:     lname,
    # TODO will redirect all user confirmation emails to alt
    # address not the fake one created for demo
    email:        "piktur.io+#{fname}#{(rand 10 * 10 * 10) - (rand 10 * 10)}@gmail.com",
    # || opts[:email] || Faker::Internet.disposable_email(fname),
    password:     'spree123',
    password_confirmation: 'spree123',
    subscribed:   true,
    created_at:   time,
    confirmed_at: time,
    expertise:    @expertise.sample,
    birthday:     date_rand(Time.parse('01/01/1950'), Time.parse('01/01/1997')) # 18.years.ago
  )
  u.spree_roles << Spree::Role.find_by!(name: 'admin')
  u.interests << @interests.sample(rand 5)

  # Spree::Role.find_by!(name: 'customer_retail').users << u

  u.bill_address = address

  # Ship to billing address
  if opts[:use_billing]
    u.ship_address = address
  # or send it offshore
  else
    u.ship_address =
      Spree::Address.find_or_create_by!(
        {
          firstname: fname,
          lastname: lname,
          address1: Faker::Address.street_address,
          address2: Faker::Address.secondary_address
        }.merge!(locality('international'))
      )
  end

  # Mock confirmation so they can submit an order
  u.confirmed_at = Time.now

  u.save!(validate: false)
  # u.confim!

  {u: u, ccd: creditcard(fname, lname, @gateway_range.shift(1)[0])}
end

# ===========================================================================
# == Sample a random product
# ===========================================================================
def random_product
  Spree::Product.all.sample
end

# http://stackoverflow.com/questions/4929078/how-to-sign-in-a-user-using-devise-from-a-rails-console
# def mock_auth
#   app.get '/login'
#   csrf_token = app.session[:_csrf_token]
#   post('/login',
#        {
#            authenticity_token: csrf_token,
#            user: {login: user.email, password: user.password}
#        }
#   )
#   # app.get '/blog'
# end

# ===========================================================================
# == Create a random order
# ===========================================================================
def random_order(options={})
  default_options = {
    user: @users.sample,
    store: Spree::Store.default,
    quantity: Range.new(1, 30).entries.sample,
    payment: false,
    status: nil
  }

  opts = options.reverse_merge(default_options)

  opts[:user][:u].valid_password?('spree123')

  # ActionController::Metal.spree_current_user
  #     @spree_current_user = opts[:user][:u]
  #   end
  # end
  # def spree_current_user
  #   opts[:user][:u]
  # end

  # @spree_current_user = opts[:user][:u]

  order = Spree::Order.create!(
    # guest_token:
    number: @invoice_range.shift(1)[0],
    # user: opts[:user][:u],
    email: opts[:user][:u].email,
    store: opts[:store],
    billing_address: opts[:user][:u].bill_address,
    shipping_address: opts[:user][:u].ship_address
  )
  # order.associate_user!(opts[:user][:u])
  order.created_at = date_rand(Time.parse('01/07/2014'), Time.parse('30/06/2015'))
  order.save!

  # order.user           = opts[:user][:u]
  # order.created_by     = opts[:user][:u]
  # order.bill_address   = opts[:user][:u].bill_address
  # order.ship_address   = opts[:user][:u].ship_address
  # order.associate_user!(opts[:user])
  # order.save!

  # Generate random number of line items
  rand(1..20).times do |i|
    product = random_product.master

    order.line_items.create!(
      variant: product,
      quantity: opts[:quantity],
      price: product.price
    )

    order.save!
  end

  order.updater.update_item_count
  order.update_totals
  order.persist_totals
  order.save!

  # order.amount

  # order.set_shipments_cost

  # if order.ship_address
  #   if order.ship_address.country.iso != 'AU'
  #     order.create_tax_charge!
  #
  #     # Or create a different adjustment
  #     # order.adjustments.create!(
  #     #   amount: order.total * 0.1,
  #     #   source: Spree::TaxRate.find_by!(name: 'GST'),
  #     #   # order: self,
  #     #   label: 'Tax',
  #     #   state: 'finalized',
  #     #   mandatory: true,
  #     #   eligible: true,
  #     #   included: true
  #     # )
  #   end
  # end

  order.special_instructions = Faker::Lorem.sentence

  if opts[:payment]
    payment = order.payments.create!(
      amount: order.total,
      payment_method: Spree::PaymentMethod.find_by(name: 'Credit Card', active: true),
      source: opts[:user][:ccd].clone
    )

    # payment.update_columns(
    #   state: 'pending',
    #   response_code: '12345'
    # )
    # order.update_payment_state
    order.finalize!
  end

  #order.create_proposed_shipments

  order.save!
  order
end



# ===========================================================================
# == Create One Hundred Users
# ===========================================================================
100.times do |i|
  user = if i < 15
    # Local metropolitan
    random_user({role: 'customer_retail', zone: 'inner_states_metro'})
  elsif i.between?(15, 30)
    # Entire state
    random_user({role: 'customer_retail', zone: 'inner_states', use_billing: false})
  elsif i.between?(30, 60)
    # International
    random_user({role: 'customer_retail', zone: 'outer_states'})
  elsif i.between?(60, 90)
    random_user({role: 'customer_retail', zone: 'national'})
  else
    random_user({role: 'customer_retail', zone: 'international'})
  end

  @users << user
end

# ===========================================================================
# == And set them to feed
# ===========================================================================
100.times do |i|
  if i < 15
    @orders << random_order

  elsif i.between?(15, 30)
    @orders << random_order

  elsif i.between?(30, 45)
    @orders << random_order

  # Outer State
  elsif i.between?(45, 60)
    @orders << random_order

  # completed
  elsif i.between?(60, 75)
    order = random_order({status: 'complete'})
    order.completed_at = order.created_at + 1.day
    order.save!
    @orders << order

  # abandoned cart
  elsif i.between?(75, 80)
    @orders << random_order({payment: true, status: 'complete'})

  # with payment
  elsif i.between?(80, 99)
    @orders << random_order({payment: true, status: 'pending'})

  elsif i == 100
    @orders << random_order({status: 'cart'})
  end
end

# @orders.each(&:create_proposed_shipments)

# select paid etc
# @orders.each do |order|
#   order.state        = 'complete'
#   order.completed_at = order.created_at + 1.day
#   order.save!
# end
