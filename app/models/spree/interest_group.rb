class Spree::InterestGroup < ActiveRecord::Base
  belongs_to :interest, class_name: 'Spree::Interest'
  belongs_to :user, class_name: 'Spree::User'
end