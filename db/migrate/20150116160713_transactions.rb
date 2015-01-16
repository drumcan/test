class Transactions < ActiveRecord::Migration
  def change
  	create_table :transactions do |t|
      t.string :transaction_id
      t.string :status
      t.string :amount
      t.string :type
      t.string :merchant_account_id
      t.string :customer_id
      t.string :payment_token
      t.timestamps
    end
  end
end
