class Spree::Interest < ActiveRecord::Base
  has_many :interest_groups, class_name: 'Spree::InterestGroup'
  has_many :users, class_name: 'Spree::User', through: :interest_groups
  has_many :products
end

