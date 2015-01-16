class Customers < ActiveRecord::Migration
  def change
  	create_table :customers do |t|
  	  t.string :first_name
  	  t.string :last_name
  	  t.string :street_address
  	  t.string :city
  	  t.string :state
  	  t.string :postal_code
      t.timestamps
    end
  end
end
