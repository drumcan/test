class Customers < ActiveRecord::Migration
  def up
  	create_table :customers do |t|
  	  t.string :first_name
  	  t.string :last_name
  	  t.string :street_address
  	  t.string :city
  	  t.string :state
  	  t.string :postal_code
      t.string :customer_id
      t.timestamps
  end
end

  def down 
  	drop_table :customers
  end
end
