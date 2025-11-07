require 'test_helper'

describe FigpayGateway::CustomerVault do
  before do
    @vault = FigpayGateway::CustomerVault.new
  end

  describe '#create' do
    it 'creates a customer vault entry' do
      VCR.use_cassette('customer_vault/create_success') do
        result = @vault.create(Fixtures.alt_card_with_billing)

        assert result.success?, "Expected customer creation to succeed, but got: #{result.response_text}"
        assert result.customer_vault_id
        assert result.customer_vault_id.to_s.length > 0

        # Cleanup
        @vault.destroy(customer_vault_id: result.customer_vault_id)
      end
    end

    it 'stores billing information' do
      VCR.use_cassette('customer_vault/create_with_billing') do
        result = @vault.create(Fixtures.alt_card_with_billing)

        assert result.success?
        assert result.customer_vault_id

        # Verify we can retrieve the customer
        find_result = @vault.find(customer_vault_id: result.customer_vault_id)
        assert find_result.success?

        # Cleanup
        @vault.destroy(customer_vault_id: result.customer_vault_id)
      end
    end

    it 'validates credit card on creation' do
      VCR.use_cassette('customer_vault/create_invalid_card') do
        invalid_data = Fixtures.alt_card_with_billing.merge(
          ccnumber: '4111111111111112' # Invalid card
        )
        result = @vault.create(invalid_data)

        refute result.success?
      end
    end
  end

  describe '#update' do
    it 'updates customer information' do
      VCR.use_cassette('customer_vault/update_success') do
        # First create a customer
        create_result = @vault.create(Fixtures.alt_card_with_billing)
        assert create_result.success?, "Customer creation failed: #{create_result.response_text}"

        # Then update the customer
        update_result = @vault.update(
          customer_vault_id: create_result.customer_vault_id,
          first_name: 'Jane',
          last_name: 'Doe-Smith',
          email: 'jane.smith@example.com'
        )

        assert update_result.success?, "Expected update to succeed, but got: #{update_result.response_text}"

        # Cleanup
        @vault.destroy(customer_vault_id: create_result.customer_vault_id)
      end
    end

    it 'updates payment information' do
      VCR.use_cassette('customer_vault/update_payment_info') do
        # Create a customer
        create_result = @vault.create(Fixtures.alt_card_with_billing)
        assert create_result.success?

        # Update with new card expiration
        update_result = @vault.update(
          customer_vault_id: create_result.customer_vault_id,
          ccexp: '1226'
        )

        assert update_result.success?

        # Cleanup
        @vault.destroy(customer_vault_id: create_result.customer_vault_id)
      end
    end
  end

  describe '#find' do
    it 'retrieves customer vault information' do
      skip "Query API not available with demo account"
    end

    it 'returns error for non-existent customer' do
      skip "Query API not available with demo account"
    end
  end

  describe '#destroy' do
    it 'deletes a customer vault entry' do
      VCR.use_cassette('customer_vault/destroy_success') do
        # First create a customer
        create_result = @vault.create(Fixtures.alt_card_with_billing)
        assert create_result.success?

        # Then delete the customer
        destroy_result = @vault.destroy(
          customer_vault_id: create_result.customer_vault_id
        )

        assert destroy_result.success?, "Expected destroy to succeed, but got: #{destroy_result.response_text}"
      end
    end
  end

  describe 'integration with transactions' do
    it 'allows charging a vaulted customer multiple times' do
      VCR.use_cassette('customer_vault/multiple_charges') do
        # Create a customer
        create_result = @vault.create(Fixtures.alt_card_with_billing)
        assert create_result.success?

        transaction = FigpayGateway::Transaction.new

        # First charge
        sale1 = transaction.sale(
          customer_vault_id: create_result.customer_vault_id,
          amount: Fixtures::AMOUNTS[:small]
        )
        assert sale1.success?, "First sale failed: #{sale1.response_text}"

        # Second charge
        sale2 = transaction.sale(
          customer_vault_id: create_result.customer_vault_id,
          amount: Fixtures::AMOUNTS[:refund]
        )
        assert sale2.success?, "Second sale failed: #{sale2.response_text}"

        # Verify different transaction IDs
        refute_equal sale1.transactionid, sale2.transactionid

        # Cleanup
        @vault.destroy(customer_vault_id: create_result.customer_vault_id)
      end
    end

    it 'supports authorize and capture with vaulted customer' do
      VCR.use_cassette('customer_vault/authorize_capture') do
        # Create a customer
        create_result = @vault.create(Fixtures.alt_card_with_billing)
        assert create_result.success?

        transaction = FigpayGateway::Transaction.new

        # Authorize
        auth_result = transaction.authorize(
          customer_vault_id: create_result.customer_vault_id,
          amount: Fixtures::AMOUNTS[:medium]
        )
        assert auth_result.success?, "Authorization failed: #{auth_result.response_text}"

        # Capture
        capture_result = transaction.capture(
          transactionid: auth_result.transactionid,
          amount: Fixtures::AMOUNTS[:medium]
        )
        assert capture_result.success?, "Capture failed: #{capture_result.response_text}"

        # Cleanup
        @vault.destroy(customer_vault_id: create_result.customer_vault_id)
      end
    end
  end
end
