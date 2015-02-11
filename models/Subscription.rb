class Subscription < ActiveRecord::Base
	belongs_to :payment_method
	
	has_many :transactions
end