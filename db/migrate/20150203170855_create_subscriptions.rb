class CreateSubscriptions < ActiveRecord::Migration
  def up
  	create_table :subscriptions do |t|
  		t.string   :subscription_id
  		t.string   :status
  		t.string   :plan_id
  		t.string   :payment_method_id
  		t.decimal  :price
  		t.string   :addon
  		t.string   :discount
  		t.boolean  :trial_period
  		t.integer  :trial_duration
  end
end


  def down
  	 drop_table :subscriptions
  end
end

