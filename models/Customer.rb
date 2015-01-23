class Customer < ActiveRecord::Base
	has_many :payment_methods
end