# def date_within_fy
#   # Create orders within fiscal year date range
#   fy_start = Time.parse('01/07/2014')
#   fy_end = Time.parse('30/06/2015')
#
#   Time.at((fy_end.to_f - fy_start.to_f) * rand + fy_start.to_f)
# end
#
# 300.times do |i|
#   fname = Faker::Name.first_name
#
#   u = Spree::User.new(
#       firstname:    fname,
#       lastname:     Faker::Name.last_name,
#       # TODO will redirect all user confirmation emails to alt
#       # address not the fake one created for demo
#       email:        Faker::Internet.disposable_email(fname),
#       password:     'spree123',
#       subscribed:   true,
#       created_at:   date_within_fy
#   )
#   u.save!(validate: false)
# end


#Convert raw data to Hash for processing
# csv = SmarterCSV.process(
#     File.join(Rails.root, 'db', 'default', 'data', '_Users.csv')
# )
#
# csv.each do |item|
#   country = Spree::Country.find_by!(iso: item[:country])
#
#   if item[:active] == 1
#     Spree::User.find_or_create_by!(
#       email:        item[:email],
#       # encrypted_password: 'spree123',
#       subscribed:   item[:subscribed],
#       # role:         item[:role],
#       ship_address_id: Spree::Address.find_or_create_by!(
#         firstname:  item[:firstname],
#         lastname:   item[:lastname],
#         company:    item[:company],
#         address1:   item[:address1],
#         address2:   item[:address2],
#         city:       item[:city],
#         state:      Spree::State.find_by!(country: country, abbr: item[:state]),
#         country:    country,
#         zipcode:    item[:postcode],
#         phone:      item[:phone] #,
#         # alt_phone:  item[:alt_phone]
#       ),
#       bill_address_id: Spree::Address.find_or_create_by!(
#         firstname:  item[:firstname],
#         lastname:   item[:lastname],
#         company:    item[:company],
#         address1:   item[:address1],
#         address2:   item[:address2],
#         city:       item[:city],
#         state:      Spree::State.find_by!(country: country, abbr: item[:state]),
#         country:    country,
#         zipcode:    item[:postcode],
#         phone:      item[:phone] #,
#         # alt_phone:  item[:alt_phone]
#       )
#     )
#   end
# end

# Spree::User.create!(
#   [
#     {
#       name: 'Daniel Small',
#       email: 'piktur.io@gmail.com',
#       role_id: 1,
#       #ship_address_id: Spree::Address.find_by!(firstname: 'Daniel'),
#       #bill_address_id: Spree::Address.find_by!(firstname: 'Daniel'),
#       subscribed: true
#     },
#
#     {
#       name: 'Staff Member',
#       email: 'piktur.io@gmail.com',
#       role_id: 1,
#       #ship_address_id: Spree::Address.find_by!(firstname: 'Daniel'),
#       #bill_address_id: Spree::Address.find_by!(firstname: 'Daniel'),
#       subscribed: true
#     },
#   ]
# )
