class Transactions < ActiveRecord::Migration
  def up
    create_table :transactions do |t|
      t.string :transaction_id
      t.string :status
      t.string :amount
      t.string :transaction_type
      t.string :payment_method_id
      t.timestamps	
  end
end

  def down
  	 drop_table :transactions
  end
end
