require "rubygems"
require "sinatra"
require 'braintree'

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = "yz2f2d9s3v4wmygp"
Braintree::Configuration.public_key = "dsybfx8t64fkmrbd"
Braintree::Configuration.private_key ="d08ad05929db33a1e0685925cb09ea43"

get "/braintree" do
  @client_token = Braintree::ClientToken.generate
  erb :braintree
end

get "/delegated" do
  @client_token = Braintree::ClientToken.generate
  erb :delegated
end

get "/sign_up" do
  erb :sign_up
end

post "/sign_up" do
  redirect "https://sandbox.braintreegateway.com/partners/demo_merchant/connect?partner_merchant_id=#{params[:partner_merchant_id]}"
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

get "/webhooks" do

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = "demo_merchant"
Braintree::Configuration.public_key = "vhd8pf4bjcxvrpy4"
Braintree::Configuration.private_key = "0210baff4bfd241592f4d4894d48b2ae"
  
  challenge = request.params["bt_challenge"]
  challenge_response = Braintree::WebhookNotification.verify(challenge)
  return [200, challenge_response]
end

post "/webhooks" do

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = "demo_merchant"
Braintree::Configuration.public_key = "vhd8pf4bjcxvrpy4"
Braintree::Configuration.private_key = "0210baff4bfd241592f4d4894d48b2ae"

  notification = Braintree::WebhookNotification.parse(params[:bt_signature], params[:bt_payload])
    puts notification.partner_merchant.merchant_public_id
    puts notification.partner_merchant.merchant_public_key
    puts notification.partner_merchant.merchant_private_key
end

get "/success" do
   erb :success
end

