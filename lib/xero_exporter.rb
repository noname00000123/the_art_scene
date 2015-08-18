class XeroExporter
  def export_new_customers

  end

  def create_contact
    @client = Xeroizer::PrivateApplication.new(
        ENV['DEMO_XERO_CONSUMER_KEY'],
        ENV['DEMO_XERO_CONSUMER_SECRET'],
        "#{Rails.root}/xero/demo/privatekey.pem"
    )

    contact = @client.Contact.build(name: "Test #{Faker::Name.last_name}")
    contact.add_address(
        type: 'STREET',
        line1: Faker::Address.street_address,
        city: Faker::Address.city
    )
    contact.add_phone(type: 'DEFAULT', number: Faker::PhoneNumber.phone_number)
    contact.save

    @client = nil


  end

  def export_order
    @client = Xeroizer::PrivateApplication.new(
        ENV['DEMO_XERO_CONSUMER_KEY'],
        ENV['DEMO_XERO_CONSUMER_SECRET'],
        "#{Rails.root}/xero/demo/privatekey.pem"
    )

    # id: 2,
    # number: "R638177528",
    # item_total: #<BigDecimal:d78ff20,'0.2032E3',18(18)>,
    # total: #<BigDecimal:d78fdb8,'0.2032E3',18(18)>,
    # state: "complete",
    # adjustment_total: #<BigDecimal:d78f930,'0.0',9(18)>,
    # user_id: 1,
    # completed_at: "2015-08-13 15:37:45",
    # bill_address_id: 3,
    # ship_address_id: 4,
    # payment_total: #<BigDecimal:d78ed50,'0.0',9(18)>,
    # shipping_method_id: nil,
    # shipment_state: "ready",
    # payment_state: "failed",
    # email: "piktur.io@gmail.com",
    # special_instructions: "",
    # created_at: "2015-08-13 15:36:15",
    # updated_at: "2015-08-13 15:37:45",
    # currency: "AUD",
    # last_ip_address: "127.0.0.1",
    # created_by_id: 1,
    # shipment_total: #<BigDecimal:d78ce10,'0.0',9(18)>,
    # additional_tax_total: #<BigDecimal:d78cbb8,'0.0',9(18)>,
    # promo_total: #<BigDecimal:d78c898,'0.0',9(18)>,
    # channel: "spree",
    # included_tax_total: #<BigDecimal:d78c410,'0.1847E2',18(18)>,
    # item_count: 8,
    # approver_id: nil,
    # approved_at: nil,
    # confirmation_delivered: true,
    # considered_risky: true,
    # guest_token: "mn5I48NSKBffc1sG0bSryQ",
    # canceled_at: nil,
    # canceler_id: nil,
    # store_id: 1,
    # state_lock_version: 4>

    order = Spree::Order.complete.first
    line_items = order.line_items
    full_name = [order.ship_address.first_name, order.ship_address.last_name].join(' ')

    # build contact
    contact = @client.Xeroizer::Record::Contact.build({
      name: "Test #{Faker::Name.last_name}",
      first_name: Faker::Name.first_name, # order.ship_address.first_name,
      last_name: Faker::Name.last_name, # order.ship_address.last_name,
      email_address: Faker::Internet.email, # order.user.email,
      contact_number: Faker::PhoneNumber.phone_number # order.ship_address.phone
    })
    contact.save

    contact.add_address(
        type: 'DELIVERY',
        line1: order.ship_address.address1,
        line2: order.ship_address.address2,
        city: order.ship_address.city,
        region: order.ship_address.state,
        postal_code: order.ship_address.zipcode,
        country: order.ship_address.country,
    )

    contact.save

    ref = order.number + rand(10 ** 10).to_s

    # build the invoice
    invoice = @client.Xeroizer::Record::Invoice.build(
        # Auto increment invoice number
        type: "ACCREF",
        invoice_number: ref,
        contact: contact,
        # Spree reference number
        reference: ref,
        line_amount_types: "Inclusive",
        currency_code: 'AUD',
        tax_type: 'OUTPUT',
        # Auto generated
        # invoice_number: "123",
        status: "DRAFT"
    )

    invoice.save

    invoice.date = Date.parse(order.created_at.strftime('%F'))
    invoice.due_date = Date.parse(2.weeks.from_now(order.created_at).strftime('%F'))

    line_items.uniq.each do |item|
      invoice.add_line_item(
          description: item.name,
          quantity: item.quantity.to_i,
          unit_amount: item.price.to_i,
          item_code: item.sku.to_s
      )

    end

    invoice.save

    @client = nil
  end

  def invoices
    render json: @client.Xeroizer::Record::Invoice.all(:where => {:type => 'ACCREC', :amount_due_is_not => 0})
  end
# # == API limits
# # A limit of 60 API calls in any 60 second period
# # A limit of 1000 API calls in any 24 hour period
#
# Xeroizer::PublicApplication.new(YOUR_OAUTH_CONSUMER_KEY,
#                                 YOUR_OAUTH_CONSUMER_SECRET,
#                                 :rate_limit_sleep => 2)
#
#
# contacts = xero.Contact.all(:order => 'Name')
#
# contact = xero.Contact.build(:name => 'Contact Name')
# contact.first_name = 'Joe'
# contact.last_name = 'Bloggs'
# # To add to a has_many association use the +add_{association}+ method
# contact.add_address(:type => 'STREET', :line1 => '12 Testing Lane', :city => 'Brisbane')
# contact.add_phone(:type => 'DEFAULT', :area_code => '07', :number => '3033 1234')
# contact.add_phone(:type => 'MOBILE', :number => '0412 123 456')
# contact.save
#
# Xero.Invoice.all(:where => {:type => 'ACCREC', :amount_due_is_not => 0})
#
# # To add to a belongs_to association use the +build_{association}+ method.
# invoices = xero.Invoice.all(:where => 'Contact.ContactID.ToString()=="cd09aa49-134d-40fb-a52b-b63c6a91d712"')
# invoice.build_contact(:name => 'ABC Company')
#
#
# # == Batch creates
# contact1 = xero.Contact.create(some_attributes)
# xero.Contact.batch_save do
#   contact1.email_address = "foo@bar.com"
#   contact2 = xero.Contact.build(some_other_attributes)
#   contact3 = xero.Contact.build(some_more_attributes)
# end
end