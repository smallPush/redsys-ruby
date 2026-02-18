# RedsysRuby

A Ruby gem for making payments with Redsys using the HMAC-SHA256 signature algorithm.

**Note:** This documentation and some parts of the code use Spanish terms because Redsys is a payment provider that operates in Spain.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'redsys-ruby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install redsys-ruby

### Rails Integration

This gem includes a Rails Engine that provides a configuration interface, payment helpers, and premium success/failure pages.

#### 1. Mount the Engine

Add the following to your `config/routes.rb`:

```ruby
mount RedsysRuby::Engine => "/redsys_ruby"
```

#### 2. Configuration

You can configure your Redsys credentials through the provided UI at `/redsys_ruby/configuration/edit`. This will save a `config/redsys.yml` file in your Rails application.

Alternatively, you can manually create `config/redsys.yml`:

```yaml
development:
  merchant_key: "your_merchant_key_base64"
  merchant_code: "999008881"
  terminal: "001"
  environment: "test"
```

#### 3. Using the Payment Form Helper

In your views, you can use the `redsys_payment_form` helper to generate a payment form that redirects to Redsys:

```erb
<%= redsys_payment_form(amount: 10.50, order: "123456789012", description: "Product description") %>
```

The helper automatically includes:
- **Ds_SignatureVersion**
- **Ds_MerchantParameters**
- **Ds_Signature**
- **Ds_Merchant_UrlOK**: Points to the built-in premium success page.
- **Ds_Merchant_UrlKO**: Points to the built-in premium failure page.

### Premium Success & Failure Pages

The gem provides beautifully designed `Ok` and `KO` pages that match modern aesthetics, featuring:
- Inter typography.
- Smooth gradients and micro-animations.
- Responsive design.
- Backdrop blur effects.

---

### Low-level Ruby Usage (Non-Rails)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/smallpush/redsys-ruby.
