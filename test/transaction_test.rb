require 'test_helper'

describe FigpayGateway::Transaction do
  before do
    @transaction = FigpayGateway::Transaction.new
  end

  describe '#validate' do
    it 'validates a valid credit card' do
      VCR.use_cassette('transaction/validate_valid_card') do
        result = @transaction.validate(Fixtures.minimal_card_data)

        assert result.success?, "Expected validation to succeed, but got: #{result.response_text}"
      end
    end

    it 'rejects an invalid credit card' do
      VCR.use_cassette('transaction/validate_invalid_card') do
        invalid_data = Fixtures.minimal_card_data.merge(ccnumber: '4111111111111112')
        result = @transaction.validate(invalid_data)

        refute result.success?
      end
    end
  end

  describe '#sale' do
    it 'processes a sale transaction successfully' do
      VCR.use_cassette('transaction/sale_success') do
        result = @transaction.sale(
          Fixtures.card_with_billing.merge(amount: Fixtures::AMOUNTS[:small])
        )

        assert result.success?, "Expected sale to succeed, but got: #{result.response_text}"
        assert result.transactionid
        refute_nil result.authcode
      end
    end

    it 'includes transaction ID in successful response' do
      VCR.use_cassette('transaction/sale_with_transaction_id') do
        result = @transaction.sale(
          Fixtures.card_with_billing.merge(amount: Fixtures::AMOUNTS[:small])
        )

        assert result.success?
        assert result.transactionid
        assert result.transactionid.to_s.length > 0
      end
    end

    it 'handles declined transactions' do
      skip "Demo account approves all transactions"
    end
  end

  describe '#authorize' do
    it 'creates an authorization' do
      VCR.use_cassette('transaction/authorize_success') do
        result = @transaction.authorize(
          Fixtures.minimal_card_data.merge(amount: Fixtures::AMOUNTS[:medium])
        )

        assert result.success?, "Expected authorization to succeed, but got: #{result.response_text}"
        assert result.transactionid
        assert result.authcode
      end
    end
  end

  describe '#capture' do
    it 'captures a previously authorized transaction' do
      VCR.use_cassette('transaction/capture_success') do
        # First create an authorization
        auth_result = @transaction.authorize(
          Fixtures.minimal_card_data.merge(amount: Fixtures::AMOUNTS[:medium])
        )
        assert auth_result.success?, "Authorization failed: #{auth_result.response_text}"

        # Then capture it
        capture_result = @transaction.capture(
          transactionid: auth_result.transactionid,
          amount: Fixtures::AMOUNTS[:medium]
        )

        assert capture_result.success?, "Expected capture to succeed, but got: #{capture_result.response_text}"
      end
    end

    it 'allows partial capture' do
      VCR.use_cassette('transaction/capture_partial') do
        auth_result = @transaction.authorize(
          Fixtures.minimal_card_data.merge(amount: Fixtures::AMOUNTS[:medium])
        )
        assert auth_result.success?

        # Capture less than the authorized amount
        capture_result = @transaction.capture(
          transactionid: auth_result.transactionid,
          amount: Fixtures::AMOUNTS[:small]
        )

        assert capture_result.success?
      end
    end
  end

  describe '#credit' do
    it 'processes a standalone credit' do
      VCR.use_cassette('transaction/credit_standalone') do
        result = @transaction.credit(
          Fixtures.minimal_card_data.merge(amount: Fixtures::AMOUNTS[:refund])
        )

        assert result.success?, "Expected credit to succeed, but got: #{result.response_text}"
        assert result.transactionid
      end
    end
  end

  describe '#refund' do
    it 'refunds a previous transaction' do
      VCR.use_cassette('transaction/refund_success') do
        # First create a sale
        sale_result = @transaction.sale(
          Fixtures.card_with_billing.merge(amount: Fixtures::AMOUNTS[:small])
        )
        assert sale_result.success?, "Sale failed: #{sale_result.response_text}"

        # Then refund it
        refund_result = @transaction.refund(
          transactionid: sale_result.transactionid,
          amount: Fixtures::AMOUNTS[:refund]
        )

        assert refund_result.success?, "Expected refund to succeed, but got: #{refund_result.response_text}"
      end
    end

    it 'allows partial refund' do
      VCR.use_cassette('transaction/refund_partial') do
        sale_result = @transaction.sale(
          Fixtures.card_with_billing.merge(amount: Fixtures::AMOUNTS[:small])
        )
        assert sale_result.success?

        # Refund only part of the sale
        refund_result = @transaction.refund(
          transactionid: sale_result.transactionid,
          amount: Fixtures::AMOUNTS[:refund]
        )

        assert refund_result.success?
      end
    end
  end

  describe '#void' do
    it 'voids a transaction' do
      skip "Void requires transaction to be in pending settlement status"
    end
  end

  describe '#find' do
    it 'retrieves transaction details' do
      skip "Query API not available with demo account"
    end
  end

  describe '#update' do
    it 'updates transaction metadata' do
      VCR.use_cassette('transaction/update_success') do
        # First create a transaction
        sale_result = @transaction.sale(
          Fixtures.card_with_billing.merge(amount: Fixtures::AMOUNTS[:small])
        )
        assert sale_result.success?

        # Then update it
        update_result = @transaction.update(
          transactionid: sale_result.transactionid,
          orderid: 'TEST-ORDER-123',
          order_description: 'Test order updated'
        )

        assert update_result.success?, "Expected update to succeed, but got: #{update_result.response_text}"
      end
    end
  end

  describe 'vaulted customer transactions' do
    it 'charges a vaulted customer' do
      VCR.use_cassette('transaction/charge_vaulted_customer') do
        # First create a customer vault
        vault = FigpayGateway::CustomerVault.new
        vault_result = vault.create(Fixtures.alt_card_with_billing)
        assert vault_result.success?, "Vault creation failed: #{vault_result.response_text}"

        # Then charge the vaulted customer
        sale_result = @transaction.sale(
          customer_vault_id: vault_result.customer_vault_id,
          amount: Fixtures::AMOUNTS[:medium],
          orderid: 'VAULT-ORDER-456'
        )

        assert sale_result.success?, "Expected vaulted sale to succeed, but got: #{sale_result.response_text}"
        assert sale_result.transactionid

        # Cleanup
        vault.destroy(customer_vault_id: vault_result.customer_vault_id)
      end
    end
  end
end
