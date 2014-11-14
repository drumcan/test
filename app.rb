require "rubygems"
require "sinatra"
require 'braintree'

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = "yz2f2d9s3v4wmygp"
Braintree::Configuration.public_key = "dsybfx8t64fkmrbd"
Braintree::Configuration.private_key = "d08ad05929db33a1e0685925cb09ea43"

get "/braintree" do
  @client_token = Braintree::ClientToken.generate
  erb :braintree
end

get "/delegated" do
  @client_token = Braintree::ClientToken.generate
  erb :delegated
end

get "/3dsecure" do
  @client_token = Braintree::ClientToken.generate
  erb :threeds
end


post "/checkout" do
  result = Braintree::Transaction.sale(
    :merchant_account_id => "magento",
    :amount => "10.00",
    :payment_method_nonce => params[:payment_method_nonce],
    :device_data => params[:device_data],
    :options => {
      :store_in_vault => true,
      :submit_for_settlement => true
  }
  )
  if result.success?
    "Success ID: #{result.transaction.id}"
  else
    result.message
  end
end

post "/create_threeds" do 
  result = Braintree::Transaction.sale(
  :amount => "50",
  :credit_card => {
    :number => params[:number],
    :expiration_date => params[:date]
  },
  :three_d_secure_token => params[:three_d_secure_token]
)
if result.success?
    "Success ID: #{result.transaction.id}"
  else
    result.message
  end
end
