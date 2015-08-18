class AddColumnsToSpreeUsers < ActiveRecord::Migration
  def self.up
    create_table :spree_interest_groups do |t|
      t.integer :user_id
      t.integer :interest_id
    end

    create_table :spree_interests do |t|
      t.string   :interest
    end

    change_table :spree_users do |t|
      t.string  :firstname
      t.string  :lastname
      t.date    :birthday
      t.string  :expertise
    end
  end

  def self.down
    change_table :spree_users do |t|
      t.remove :expertise
      t.remove :birthday
      t.remove :lastname
      t.remove :firstname
    end

    drop_table :spree_interests

    drop_table :spree_interest_groups
  end
end
