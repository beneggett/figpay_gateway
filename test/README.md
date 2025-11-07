# FigPay Gateway Tests

This directory contains automated tests for the FigPay Gateway gem, covering transactions, customer vault operations, and recurring billing.

## Test Setup

Tests use:
- **Minitest** with spec-style `describe`/`it` blocks
- **VCR** for recording and replaying HTTP interactions
- **WebMock** for stubbing HTTP requests
- **Fixtures** for test data (credit cards, customer info, amounts)

## Running Tests

```bash
# Run all tests
bundle exec rake test

# Run a specific test file
bundle exec ruby -Ilib:test test/transaction_test.rb

# Run with verbose output
bundle exec rake test TESTOPTS="--verbose"
```

## Test Coverage

### Transaction Tests (`transaction_test.rb`)
- Card validation
- Sale transactions
- Authorization and capture
- Standalone credits
- Refunds (full and partial)
- Transaction updates
- Vaulted customer transactions

### Customer Vault Tests (`customer_vault_test.rb`)
- Creating customer vault entries
- Updating customer information
- Updating payment information
- Deleting customers
- Multiple charges to vaulted customers
- Authorization and capture with vaulted customers

### Recurring Billing Tests (`recurring_test.rb`)
- Creating billing plans
- Subscribing customers to plans
- Creating custom subscriptions
- Updating subscriptions
- Canceling subscriptions
- Complete subscription lifecycle

## VCR Cassettes

HTTP interactions are recorded in `test/vcr_cassettes/`. Sensitive data is automatically filtered:

- `NMI_SECURITY_KEY` - replaced with `<NMI_SECURITY_KEY>`
- Credit card numbers - replaced with `<CREDIT_CARD>`
- CVV codes - replaced with `<CVV>`

To re-record cassettes, delete the relevant `.yml` files and run the tests again.

## Skipped Tests

Some tests are skipped when using the demo account due to API limitations:

- **Query API tests**: The NMI demo account doesn't support the Query API, so tests for finding transactions and customers are skipped
- **Void transactions**: Voiding requires transactions to be in pending settlement status
- **Declined transactions**: Demo account approves all transactions
- **Subscription frequency updates**: May have API limitations

## Fixtures

Test data is defined in `test/fixtures.rb`:

```ruby
# Valid test cards
Fixtures::VALID_VISA
Fixtures::VALID_MASTERCARD

# Customer billing information
Fixtures::BILLING_INFO
Fixtures::BILLING_INFO_ALT

# Transaction amounts
Fixtures::AMOUNTS[:small]    # 10.00
Fixtures::AMOUNTS[:medium]   # 25.00
Fixtures::AMOUNTS[:large]    # 100.00
Fixtures::AMOUNTS[:refund]   # 5.00
```

## CI Integration

Tests run automatically in GitHub Actions on:
- Pull requests to any branch
- Pushes to `main` or `master`
- Multiple Ruby versions (3.0, 3.1, 3.2, 3.3, 3.4)

## Manual Testing

For manual/exploratory testing, use:

```bash
bin/test_all_methods
```

This script runs through all major API operations and provides detailed output for each call.
