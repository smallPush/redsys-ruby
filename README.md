# RedsysRuby

A Ruby gem for making payments with Redsys using the HMAC-SHA256 signature algorithm.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'redsys_ruby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install redsys_ruby

## Usage

### Initializing the TPV

```ruby
require 'redsys_ruby'

tpv = RedsysRuby::TPV.new(merchant_key: 'your_merchant_key_base64')
```

### Preparing Payment Data

```ruby
params = {
  Ds_Merchant_Amount: "145", # In cents
  Ds_Merchant_Order: "0001",
  Ds_Merchant_MerchantCode: "999008881",
  Ds_Merchant_Currency: "978",
  Ds_Merchant_TransactionType: "0",
  Ds_Merchant_Terminal: "1",
  Ds_Merchant_MerchantURL: "https://your-domain.com/notifications",
  Ds_Merchant_UrlOK: "https://your-domain.com/ok",
  Ds_Merchant_UrlKO: "https://your-domain.com/ko"
}

payment_data = tpv.payment_data(params)
# Returns a hash with:
# :Ds_SignatureVersion
# :Ds_MerchantParameters
# :Ds_Signature
```

### Verifying a Notification

```ruby
merchant_parameters_64 = params[:Ds_MerchantParameters]
signature = params[:Ds_Signature]

if tpv.valid_signature?(merchant_parameters_64, signature)
  decoded_params = tpv.decode_parameters(merchant_parameters_64)
  # Handle the payment status
  if decoded_params["Ds_Response"].to_i < 100
    # Success
  else
    # Failure
  end
else
  # Invalid signature
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/google-labs/redsys_ruby.
