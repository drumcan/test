require "rubygems"
require 'sinatra'
require "sinatra/activerecord"
require 'braintree'


t_config = Braintree::Configuration.new(:environment => :sandbox, 
                               :merchant_id => "yz2f2d9s3v4wmygp", 
                                :public_key => "dsybfx8t64fkmrbd", 
                               :private_key => "d08ad05929db33a1e0685925cb09ea43")
p_config = Braintree::Configuration.new(:environment => :sandbox, 
                               :merchant_id => "demo_merchant", 
                                :public_key => "vhd8pf4bjcxvrpy4", 
                               :private_key => "0210baff4bfd241592f4d4894d48b2ae")

t_gateway = Braintree::Gateway.new(t_config)
p_gateway = Braintree::Gateway.new(p_config)

configure :development, :test do
  set :database, 'sqlite3:development.db'
end

configure :production do
  # Database connection
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
 
  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )
end

get "/" do
  @title = "Index"
  erb :index
end

get "/braintree" do
  @title = "Partners"
  @partners = Partners.all
  erb :braintree
end

get "/threedsecure" do
  @title = "3D Secure"
  @client_token = t_gateway.client_token.generate
  erb :threedsecure
end

get "/delegated" do
  @title = "Dropin UI"
  @client_token = t_gateway.client_token.generate
  erb :delegated
end

get "/shipping" do
  @title = "Paypal with Shipping Address" 
  @client_token = t_gateway.client_token.generate
  erb :shipping
end

get "/sign_up" do
  @title = "Partners Signup"
  erb :sign_up
end

get "/stored_customer" do 
  @title = "Dropin with Existing Customer"
  @client_token = t_gateway.client_token.generate(
    :customer_id => "60378774")   
  erb :store_customer
end

post "/sign_up" do
  @title = "Partners Signup"
  redirect "https://sandbox.braintreegateway.com/partners/demo_merchant/connect?partner_merchant_id=#{params[:partner_merchant_id]}"
end

post "/threedcheckout" do

result = t_gateway.transaction.sale(
  :amount => "100.00",
  :payment_method_nonce => params[:nonce],
  :options => {
    :three_d_secure => {
      :required => true
    }
  }
)

if result.success?
 "Success ID: #{result.transaction.id}"
  else
    result.message
  end
end

post "/checkout" do
  result = t_gateway.transaction.sale(
    :merchant_account_id => "magento",
    :amount => "10.00",
    :payment_method_nonce => params[:payment_method_nonce],
    :customer => {
      :first_name => params[:first_name],
      :last_name => params[:last_name]
    },
    :billing => {
      :street_address => params[:street_address],
      :locality => params[:city],
      :region => params[:state],
      :postal_code => params[:postal_code]
    },
    :shipping => {
      :street_address => params[:street_address],
      :locality => params[:city],
      :region => params[:state],
      :postal_code => params[:postal_code]
    },
    :device_data => params[:device_data],
    :options => {
      :store_in_vault => true,
      :submit_for_settlement => false
    }
  )
  if result.success?
    transaction = Transaction.new
    transaction.transaction_id = result.transaction.id
    transaction.status = result.transaction.status
    transaction.amount = result.transaction.amount
    transaction.transaction_type = result.transaction.type
    if result.transaction.payment_instrument_type == "credit_card"
    transaction.payment_method_id = result.transaction.credit_card_details.token
    elsif result.transaction.payment_instrument_type == "paypal_account" 
    transaction.payment_method_id = result.transaction.paypal_details.token
    end
    transaction.save


    
    customer = Customer.new
    customer.first_name = result.transaction.customer_details.first_name
    customer.last_name = result.transaction.customer_details.last_name
    customer.street_address = result.transaction.billing_details.street_address
    customer.city = result.transaction.billing_details.locality
    customer.state = result.transaction.billing_details.region
    customer.postal_code = result.transaction.billing_details.postal_code
    customer.customer_id = result.transaction.customer_details.id
    customer.save

    payment_method = PaymentMethod.new
    if result.transaction.payment_instrument_type == "credit_card"
    payment_method.payment_token = result.transaction.credit_card_details.token
    elsif result.transaction.payment_instrument_type == "paypal_account" 
    payment_method.payment_token = result.transaction.paypal_details.token
    end
    payment_method.payment_instrument_type = result.transaction.payment_instrument_type
    payment_method.customer_id = result.transaction.customer_details.id
    payment_method.save

    "Success ID: #{result.transaction.id}"
  else
    result.message
  end
end

=begin post "/create_subscription"

 result = Braintree::Subscription.create(
      :payment_method_token => params[:payment_token],
      :plan_id => "test_plan_1"
    )

   
  

  subscription = Subscription.new
  subscription.subscription_id = result.subscription.id
  subscription.status = result.subscription.status
  subscription.plan_id = result.subscription.plan
  subscription.payment_method = result.subscription.payment_method_token
  subscription.price = result.subscription.price
  subscription.addon = 
  subscription.discount = 
  subscription.trial_period = result.subscription.trial_period
  subscription.trial_duration = result.subscription.trial_duration

=end 
get '/transactions' do
  @title = "Tranasction Table"
  @transactions = Transaction.all
  erb :transactions
end

get '/customer_select' do
  @title = "Customer select"
  @customers = Customer.all
  erb :braintree
end

post '/find_customer' do
  @payment_method = PaymentMethod.find_by :customer_id => params[:customer_id]
  @customer = Customer.find_by :customer_id => params[:customer_id]
  @transactions = Transaction.where :payment_method_id => @payment_method.payment_token
  erb :payment_method_for_customer
  
end 

get '/customers' do
  @title = "Customers"
  @customers = Customer.all
  erb :customers
end

get '/payment_methods' do 
   @title = "Payment Methods"
   @payment_methods = PaymentMethod.all
   erb :payment_methods

end 

get "/merchant_create" do 
  @title = "Submerchant Create Form"
  erb :merchant_create
end

post "/merchant_create" do 

  @title = "Merchant Created Successfully"

  if params[:merchant_account] == "Approve" 
  @decision = Braintree::Test::MerchantAccount::Approve
elsif params[:merchant_account] == "DeclinedOFAC"
  @decision = Braintree::ErrorCodes::MerchantAccount::ApplicantDetails::DeclinedOFAC
elsif params[:merchant_account]  == "DeclinedMasterCardMatch"
  @decision = Braintree::ErrorCodes::MerchantAccount::ApplicantDetails::DeclinedMasterCardMatch
elsif params[:merchant_account]  == "DeclinedSsnMatchesDeceased"
  @decision = Braintree::ErrorCodes::MerchantAccount::ApplicantDetails::DeclinedSsnMatchesDeceased
elsif params[:merchant_account]  == "DeclinedFailedKYC"
  @decision = Braintree::ErrorCodes::MerchantAccount::ApplicantDetails::DeclinedFailedKYC
end
  
  @number = Time.now.to_s.tr('^A-Za-z0-9', '')

  result = t_gateway.merchant_account.create(
    :individual => {
      :first_name => @decision,
      :last_name => params[:last_name],
      :email => params[:email],
      :phone => params[:phone],
      :date_of_birth => params[:date_of_birth],
      :ssn => params[:ssn],
      :address => {
        :street_address => params[:street_address],
        :locality => params[:locality],
        :region => params[:region],
        :postal_code => params[:postal_code]
    }},
    :funding => {
      :destination => Braintree::MerchantAccount::FundingDestination::Bank,
      :account_number => params[:account_number],
      :routing_number => params[:routing_number]
    },
    :tos_accepted => true,
    :master_merchant_account_id => "hdpcgvhz4rhydzf3",
    :id => @number
  )
  
  if result.success?
      "Success! Status: #{result.merchant_account.status}"
      erb :index 
  else
     result.message
  end
end

get "/webhooks_merchant_account" do

challenge = request.params["bt_challenge"]
  challenge_response = t_gateway.webhook_notification.verify(challenge)
  return [200, challenge_response]
end

post "/webhooks_merchant_account" do

notification = t_gateway.webhook_notification.parse(
    request.params["bt_signature"],
    request.params["bt_payload"]
  )
  if notification.kind == Braintree::WebhookNotification::
                               Kind::SubMerchantAccountApproved
    merchant_account = MerchantAccount.new
    merchant_account.status = notification.merchant_account.status
    merchant_account.merchant_account_id = notification.merchant_account.id
    merchant_account.save
    puts "[Webhook Received #{notification.timestamp}] Kind: #{notification.kind}"
    return 200
  else 
    merchant_account = MerchantAccount.new
    merchant_account.status = notification.message
    merchant_account.merchant_account_id = notification.merchant_account.id
    merchant_account.save
    puts "[Webhook Received #{notification.timestamp}] Kind: #{notification.kind}"
    return 200
  end
end

get "/merchants" do
  @title = "Submerchants"
  @merchants = MerchantAccount.all
  erb :merchants
end

get "/webhooks" do
  
  challenge = request.params["bt_challenge"]
  challenge_response = p_gateway.webhook_notification.verify(challenge)
  return [200, challenge_response]
end

post "/webhooks" do

    notification = p_gateway.webhook_notification.parse(request.params["bt_signature"],
                                                        request.params["bt_payload"])
    partner = Partners.new
    partner.partners_merchant_id = notification.partner_merchant.partner_merchant_id
    partner.merchant_public_id = notification.partner_merchant.merchant_public_id
    partner.merchant_public_key = notification.partner_merchant.merchant_public_key
    partner.merchant_private_key = notification.partner_merchant.merchant_private_key
    partner.save
    puts "[Webhook Received #{notification.timestamp}] Kind: #{notification.kind}"
    return 200
end

get "/partners" do
  @partners = Partners.all
  erb :partners
end

get "/success" do
   erb :success
end

