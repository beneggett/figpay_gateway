[![Gem Version](https://badge.fury.io/rb/figpay_gateway.svg)](https://badge.fury.io/rb/figpay_gateway)

# FigPay Gateway Ruby Library

The FigPay Gateway Ruby library provides convenient access to the FigPay payment gateway API from applications written in Ruby. FigPay is a white-label payment gateway powered by NMI, and this library is built with portability in mind for other NMI-based gateways.

## Documentation

See the [FigPay API documentation](https://www.figpay.com/) for detailed information about the payment gateway features.

## Requirements

- Ruby 3.0.0 or higher

## Installation

Install the gem and add to your application's Gemfile:

```bash
gem install figpay_gateway
```

Or add this line to your Gemfile:

```ruby
gem 'figpay_gateway'
```

And then execute:

```bash
bundle install
```

## Usage

The library needs to be configured with your account's security key, which is available in your FigPay merchant control panel under Settings > Security Keys.

### Configuration

You can configure the library in two ways:

#### Option 1: Environment Variables

Set your security key as an environment variable:

```bash
export NMI_SECURITY_KEY='your_security_key_here'
```

Or in a `.env` file:

```
NMI_SECURITY_KEY=your_security_key_here
```

For testing, you can use the demo account security key:

```
NMI_SECURITY_KEY=6457Thfj624V5r7WUwc5v6a68Zsd6YEm
```

#### Option 2: Initializer (Recommended for Rails)

Create an initializer file (e.g., `config/initializers/figpay_gateway.rb`):

```ruby
FigpayGateway.configure do |config|
  config.security_key = Rails.application.credentials.dig(:nmi, :security_key)
  # Optional: customize gateway URLs (defaults shown)
  # config.transaction_url = 'https://figpay.transactiongateway.com/api/transact.php'
  # config.query_url = 'https://figpay.transactiongateway.com/api/query.php'
  # config.test_mode = 'enabled' # Enable test mode
end
```

**Note:** You can use either `FigpayGateway.configure` or `NMIGateway.configure` - both work identically. Configuration values set via the initializer take precedence over environment variables.

### Quick Start

```ruby
require 'figpay_gateway'

# Process a sale
result = FigpayGateway::Transaction.new.sale(
  ccnumber: '4111111111111111',
  ccexp: '1225',
  amount: 10.00,
  first_name: 'John',
  last_name: 'Doe',
  email: 'john@example.com'
)

if result.success?
  puts "Transaction approved: #{result.transactionid}"
else
  puts "Transaction failed: #{result.response_text} #{result.response_message}"
end
```

## API Overview

The FigPay Gateway library is organized around three main API sets:

### Transactions

Process credit card transactions including sales, authorizations, captures, and refunds.

#### Recommendation - use collect.js to tokenize cards client side

The payment gateway supports credit card tokenization via [Collect.js](https://figpay.transactiongateway.com//merchants/resources/integration/integration_portal.php#cjs_methodology). The benefit of this approach is that sensitive PCI information will be submitted directly to payment processor servers, they will return a token that you would send back to your servers, and reduce the PCI SAQ compliance requirements from SAQ-C or SAQ-D to SAQ-A. This greatly simplifies compliance, as no credit information would ever touch your logs or servers.

Test Token example: `00000000-000000-000000-000000000000`
This is tied to a test card: `Card: 4111111111111111, Expiration: October 2025, CVV: 999`

Usage, in all examples, rather than passing in `ccnumber` and `ccexp`, these can be updated to use the token obtained via Collect.js and passed in as a `payment_token` param instead.

There is a Test Public Key that can be used with Collect.js: `48r3R6-M39Jx5-467srN-VWVbD3`

#### Create a Sale

Process a direct sale (authorization and capture combined):

```ruby
transaction = FigpayGateway::Transaction.new

result = transaction.sale(
  ccnumber: '4111111111111111',
  ccexp: '1225',
  cvv: '999',
  amount: 25.00,
  first_name: 'John',
  last_name: 'Doe',
  address1: '123 Main St',
  city: 'Beverly Hills',
  state: 'CA',
  zip: '90210',
  country: 'US',
  email: 'john@example.com'
)
```

#### Authorize and Capture

Authorize a payment for later capture:

```ruby
# Authorize
auth = FigpayGateway::Transaction.new.authorize(
  ccnumber: '4111111111111111',
  ccexp: '1225',
  amount: 50.00,
  first_name: 'John',
  last_name: 'Doe'
)

# Capture the authorized amount
if auth.success?
  capture = FigpayGateway::Transaction.new.capture(
    transactionid: auth.transactionid,
    amount: 50.00
  )
end
```

#### Refund a Transaction

Issue a refund for a previous transaction:

```ruby
refund = FigpayGateway::Transaction.new.refund(
  transactionid: '3261844010',
  amount: 10.00
)
```

#### Void a Transaction

Void a transaction before it settles:

```ruby
void = FigpayGateway::Transaction.new.void(
  transactionid: '3261830498'
)
```

#### Credit (Standalone Credit)

Issue a credit without a previous transaction:

```ruby
credit = FigpayGateway::Transaction.new.credit(
  ccnumber: '4111111111111111',
  ccexp: '1225',
  amount: 15.00,
  first_name: 'John',
  last_name: 'Doe'
)
```

#### Validate a Card

Validate card details without charging:

```ruby
validation = FigpayGateway::Transaction.new.validate(
  ccnumber: '4111111111111111',
  ccexp: '1225',
  first_name: 'John',
  last_name: 'Doe'
)
```

#### Query a Transaction

Retrieve transaction details:

```ruby
details = FigpayGateway::Transaction.new.find(
  transaction_id: '3261844010'
)
```

#### Update Transaction Information

Update transaction details (e.g., order information):

```ruby
update = FigpayGateway::Transaction.new.update(
  transactionid: '3261844010',
  orderid: 'ORDER-12345',
  order_description: 'Updated order description'
)
```

### Customer Vault

Store customer payment information securely for future transactions.

#### Create a Customer

Store customer payment details in the vault:

```ruby
vault = FigpayGateway::CustomerVault.new

customer = vault.create(
  ccnumber: '4111111111111111',
  ccexp: '1225',
  cvv: '999',
  first_name: 'Jane',
  last_name: 'Smith',
  address1: '456 Oak Ave',
  city: 'Los Angeles',
  state: 'CA',
  zip: '90001',
  email: 'jane@example.com'
)

if customer.success?
  puts "Customer created: #{customer.customer_vault_id}"
end
```

#### Update a Customer

Update stored customer information:

```ruby
update = FigpayGateway::CustomerVault.new.update(
  customer_vault_id: '481397475',
  ccnumber: '4111111111111111',
  ccexp: '0226',
  first_name: 'Jane',
  last_name: 'Doe',
  email: 'jane.doe@example.com'
)
```

#### Delete a Customer

Remove a customer from the vault:

```ruby
delete = FigpayGateway::CustomerVault.new.destroy(
  customer_vault_id: '481397475'
)
```

#### Retrieve Customer Details

Query customer vault information:

```ruby
customer = FigpayGateway::CustomerVault.new.find(
  customer_vault_id: '481397475'
)
```

#### Charge a Vaulted Customer

Process a transaction using stored payment information:

```ruby
sale = FigpayGateway::Transaction.new.sale(
  customer_vault_id: '481397475',
  amount: 99.99,
  orderid: 'ORDER-67890'
)
```

### Recurring Billing

Set up and manage recurring subscription payments.

#### Create a Billing Plan

Define a reusable billing plan:

```ruby
recurring = FigpayGateway::Recurring.new

plan = recurring.create_plan(
  plan_id: 'monthly-premium',
  plan_name: 'Monthly Premium Plan',
  plan_amount: 29.99,
  month_frequency: 1,
  day_of_month: 1
)
```

#### Subscribe Customer to a Plan

Add a vaulted customer to an existing plan:

```ruby
subscription = FigpayGateway::Recurring.new.add_subscription_to_plan(
  plan_id: 'monthly-premium',
  customer_vault_id: '664625840'
)

if subscription.success?
  puts "Subscription created: #{subscription.subscription_id}"
end
```

#### Create a Custom Subscription

Create a one-off subscription without a predefined plan:

```ruby
custom_sub = FigpayGateway::Recurring.new.add_custom_subscription(
  customer_vault_id: '664625840',
  plan_amount: 49.99,
  month_frequency: 3,
  day_of_month: 15,
  start_date: '20251215'
)
```

#### Update a Subscription

Modify subscription details:

```ruby
update = FigpayGateway::Recurring.new.update_subscription(
  subscription_id: '3261766445',
  plan_amount: 39.99
)
```

#### Cancel a Subscription

Delete an active subscription:

```ruby
cancel = FigpayGateway::Recurring.new.delete_subscription(
  subscription_id: '3261766445'
)
```

## Advanced Configuration

### Custom API Endpoints

Override the default FigPay API endpoints if needed:

```bash
export NMI_TRANSACTION_URL='https://custom.gateway.com/api/transact.php'
export NMI_QUERY_URL='https://custom.gateway.com/api/query.php'
```

### Per-Request Configuration

Pass a custom security key for individual requests:

```ruby
transaction = FigpayGateway::Transaction.new(security_key: 'custom_key_here')
result = transaction.sale(amount: 10.00, ...)
```

## Response Handling

All API methods return response objects with helpful methods:

```ruby
result = FigpayGateway::Transaction.new.sale(...)

# Check transaction status
if result.success?
  puts "Success!"
  puts "Transaction ID: #{result.transactionid}"
  puts "Auth Code: #{result.authcode}"
else
  puts "Failed: #{result.response_text} #{result.response_message}"
  puts "Response Code: #{result.response_code}"
end

# Access raw response data
puts result.response
```

## Testing

### Test All Methods Against Your Account

The gem includes a comprehensive testing tool that exercises all API methods against a live account. This is useful for:

- Verifying your account configuration
- Testing all available payment gateway features
- Ensuring your security key has the necessary permissions
- Learning how different API methods work

To run the comprehensive test suite:

```bash
bin/test_all_methods
```

By default, it uses the demo security key. To test against your own account, set your security key first:

```bash
export NMI_SECURITY_KEY='your_security_key_here'
bin/test_all_methods
```

The test script will:

- Run 18+ different API operations
- Show detailed results for each test
- Display a summary with success rate
- Help identify any configuration issues

**Note**: This will create real test transactions on your account (or the demo account if using the demo key).

### Test Credentials

Use the demo security key for testing:

```ruby
# In your test environment
ENV['NMI_SECURITY_KEY'] = '6457Thfj624V5r7WUwc5v6a68Zsd6YEm'
```

Test card numbers:

- **Visa**: 4111111111111111
- **Mastercard**: 5555555555554444
- **Amex**: 378282246310005
- **Discover**: 6011111111111117

## Development

After checking out the repo, run `bin/setup` to install dependencies:

```bash
bin/setup
```

Run the test suite:

```bash
rake test
```

Start an interactive console for experimentation:

```bash
bin/console
```

To install this gem onto your local machine:

```bash
bundle exec rake install
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/beneggett/figpay_gateway.

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Support

For issues related to:

- **This library**: Open an issue on [GitHub](https://github.com/beneggett/figpay_gateway/issues)
- **FigPay Gateway API**: Contact FigPay support
- **NMI Platform**: Refer to NMI documentation at [nmi.com](https://nmi.com)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## About

Built with portability in mind for NMI-based payment gateways.
