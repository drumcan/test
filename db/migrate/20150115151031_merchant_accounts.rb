class MerchantAccounts < ActiveRecord::Migration
  def change
  	create_table :merchant_accounts do |t|
      t.string :status
      t.string :merchant_account_id
      t.timestamps
    end
  end
end
