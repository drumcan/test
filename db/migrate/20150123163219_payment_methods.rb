class PaymentMethods < ActiveRecord::Migration
  def up
  	create_table :payment_methods do |t|
  	  t.string :payment_token
  	  t.string :payment_instrument_type
      t.string :customer_id
  	  t.timestamps
  	end
  end
   
   def down
   	 drop_table :payment_methods
   end
 end
