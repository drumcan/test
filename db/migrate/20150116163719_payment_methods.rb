class PaymentMethods < ActiveRecord::Migration
  def change
  	create_table :payment_methods do |t|
  	  t.string :pyment_token
  	  t.string :customer_id
  	  t.string :payment_instrument_type
  	  t.timestamps
  	end
  end
end
