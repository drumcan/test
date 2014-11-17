class Partners < ActiveRecord::Migration
  def change
    create_table :partners do |t|
      t.string :partners_merchant_id
      t.string :merchant_public_id
      t.string :merchant_public_key
      t.string :merchant_private_key
      t.timestamps
    end
  end
end
