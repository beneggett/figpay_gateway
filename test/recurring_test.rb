require 'test_helper'

describe FigpayGateway::Recurring do
  before do
    @recurring = FigpayGateway::Recurring.new
    @vault = FigpayGateway::CustomerVault.new
  end

  describe '#create_plan' do
    it 'creates a billing plan' do
      VCR.use_cassette('recurring/create_plan_success') do
        plan_data = Fixtures.plan_data('success')
        result = @recurring.create_plan(plan_data)

        assert result.success?, "Expected plan creation to succeed, but got: #{result.response_text}"
      end
    end

    it 'creates plan with monthly frequency' do
      VCR.use_cassette('recurring/create_plan_monthly') do
        plan_data = Fixtures.plan_data('monthly-freq')
        result = @recurring.create_plan(plan_data)

        assert result.success?
      end
    end

    it 'validates required plan parameters' do
      assert_raises(NMIGateway::Error::MissingParameters) do
        @recurring.create_plan(
          plan_id: "incomplete-#{Time.now.to_i}"
        )
      end
    end
  end

  describe '#add_subscription_to_plan' do
    it 'subscribes a customer to an existing plan' do
      VCR.use_cassette('recurring/add_subscription_to_plan', record: :all) do
        plan_id = "vcr-test-plan-sub1-#{Time.now.to_f.to_s.gsub('.', '')}"

        # Create a plan
        plan_result = @recurring.create_plan(
          plan_id: plan_id,
          plan_name: 'Test Monthly Plan',
          plan_amount: Fixtures::AMOUNTS[:subscription],
          month_frequency: 1,
          day_of_month: 1
        )
        assert plan_result.success?, "Plan creation failed: #{plan_result.response_text}"

        # Create a customer
        customer_result = @vault.create(Fixtures.alt_card_with_billing)
        assert customer_result.success?, "Customer creation failed: #{customer_result.response_text}"

        # Subscribe customer to plan
        sub_result = @recurring.add_subscription_to_plan(
          plan_id: plan_id,
          customer_vault_id: customer_result.customer_vault_id
        )

        assert sub_result.success?, "Expected subscription to succeed, but got: #{sub_result.response_text}"
        assert sub_result.subscription_id

        # Cleanup
        @recurring.delete_subscription(subscription_id: sub_result.subscription_id) if sub_result.subscription_id
        @vault.destroy(customer_vault_id: customer_result.customer_vault_id)
      end
    end

    it 'requires valid plan ID' do
      VCR.use_cassette('recurring/add_subscription_invalid_plan') do
        # Create a customer
        customer_result = @vault.create(Fixtures.alt_card_with_billing)
        assert customer_result.success?

        # Try to subscribe to non-existent plan
        sub_result = @recurring.add_subscription_to_plan(
          plan_id: 'nonexistent-plan',
          customer_vault_id: customer_result.customer_vault_id
        )

        refute sub_result.success?

        # Cleanup
        @vault.destroy(customer_vault_id: customer_result.customer_vault_id)
      end
    end

    it 'requires valid customer vault ID' do
      VCR.use_cassette('recurring/add_subscription_invalid_customer') do
        # Create a plan
        plan_data = Fixtures.plan_data('invalid-cust')
        plan_result = @recurring.create_plan(plan_data)
        assert plan_result.success?

        # Try to subscribe non-existent customer
        sub_result = @recurring.add_subscription_to_plan(
          plan_id: plan_data[:plan_id],
          customer_vault_id: 'nonexistent-customer'
        )

        refute sub_result.success?
      end
    end
  end

  describe '#add_custom_subscription' do
    it 'creates a custom subscription for a customer' do
      VCR.use_cassette('recurring/add_custom_subscription') do
        # Create a customer
        customer_result = @vault.create(Fixtures.alt_card_with_billing)
        assert customer_result.success?

        # Create custom subscription
        sub_result = @recurring.add_custom_subscription(
          customer_vault_id: customer_result.customer_vault_id,
          plan_amount: 19.99,
          month_frequency: 1,
          day_of_month: 15
        )

        assert sub_result.success?, "Expected custom subscription to succeed, but got: #{sub_result.response_text}"
        assert sub_result.subscription_id

        # Cleanup
        @recurring.delete_subscription(subscription_id: sub_result.subscription_id)
        @vault.destroy(customer_vault_id: customer_result.customer_vault_id)
      end
    end

    it 'supports different billing frequencies' do
      VCR.use_cassette('recurring/custom_subscription_quarterly') do
        # Create a customer
        customer_result = @vault.create(Fixtures.alt_card_with_billing)
        assert customer_result.success?

        # Create quarterly subscription
        sub_result = @recurring.add_custom_subscription(
          customer_vault_id: customer_result.customer_vault_id,
          plan_amount: 59.99,
          month_frequency: 3,
          day_of_month: 1
        )

        assert sub_result.success?
        assert sub_result.subscription_id

        # Cleanup
        @recurring.delete_subscription(subscription_id: sub_result.subscription_id)
        @vault.destroy(customer_vault_id: customer_result.customer_vault_id)
      end
    end
  end

  describe '#update_subscription' do
    it 'updates subscription amount' do
      VCR.use_cassette('recurring/update_subscription_amount') do
        # Create customer and subscription
        customer_result = @vault.create(Fixtures.alt_card_with_billing)
        assert customer_result.success?

        sub_result = @recurring.add_custom_subscription(
          customer_vault_id: customer_result.customer_vault_id,
          plan_amount: 19.99,
          month_frequency: 1,
          day_of_month: 15
        )
        assert sub_result.success?, "Subscription creation failed: #{sub_result.response_text}"

        # Update the subscription amount
        update_result = @recurring.update_subscription(
          subscription_id: sub_result.subscription_id,
          plan_amount: 24.99
        )

        assert update_result.success?, "Expected update to succeed, but got: #{update_result.response_text}"

        # Cleanup
        @recurring.delete_subscription(subscription_id: sub_result.subscription_id)
        @vault.destroy(customer_vault_id: customer_result.customer_vault_id)
      end
    end

    it 'updates subscription frequency' do
      skip "Subscription frequency updates may have API limitations"
    end
  end

  describe '#delete_subscription' do
    it 'cancels a subscription' do
      VCR.use_cassette('recurring/delete_subscription_success') do
        # Create customer and subscription
        customer_result = @vault.create(Fixtures.alt_card_with_billing)
        assert customer_result.success?

        sub_result = @recurring.add_custom_subscription(
          customer_vault_id: customer_result.customer_vault_id,
          plan_amount: 19.99,
          month_frequency: 1,
          day_of_month: 15
        )
        assert sub_result.success?

        # Delete the subscription
        delete_result = @recurring.delete_subscription(
          subscription_id: sub_result.subscription_id
        )

        assert delete_result.success?, "Expected deletion to succeed, but got: #{delete_result.response_text}"

        # Cleanup customer
        @vault.destroy(customer_vault_id: customer_result.customer_vault_id)
      end
    end

    it 'handles non-existent subscription gracefully' do
      VCR.use_cassette('recurring/delete_nonexistent_subscription') do
        result = @recurring.delete_subscription(
          subscription_id: 'nonexistent123'
        )

        refute result.success?
      end
    end
  end

  describe 'complete subscription lifecycle' do
    it 'creates plan, subscribes customer, updates, and cancels' do
      VCR.use_cassette('recurring/complete_lifecycle', record: :all) do
        plan_id = "vcr-test-plan-lifecycle-#{Time.now.to_f.to_s.gsub('.', '')}"

        # 1. Create a plan
        plan_result = @recurring.create_plan(
          plan_id: plan_id,
          plan_name: 'Test Monthly Plan',
          plan_amount: Fixtures::AMOUNTS[:subscription],
          month_frequency: 1,
          day_of_month: 1
        )
        assert plan_result.success?, "Plan creation failed: #{plan_result.response_text}"

        # 2. Create a customer
        customer_result = @vault.create(Fixtures.alt_card_with_billing)
        assert customer_result.success?, "Customer creation failed: #{customer_result.response_text}"

        # 3. Subscribe customer to plan
        sub_result = @recurring.add_subscription_to_plan(
          plan_id: plan_id,
          customer_vault_id: customer_result.customer_vault_id
        )
        assert sub_result.success?, "Subscription failed: #{sub_result.response_text}"
        assert sub_result.subscription_id

        # 4. Update subscription
        update_result = @recurring.update_subscription(
          subscription_id: sub_result.subscription_id,
          plan_amount: 34.99
        )
        assert update_result.success?, "Update failed: #{update_result.response_text}"

        # 5. Cancel subscription
        cancel_result = @recurring.delete_subscription(
          subscription_id: sub_result.subscription_id
        )
        assert cancel_result.success?, "Cancellation failed: #{cancel_result.response_text}"

        # Cleanup
        @vault.destroy(customer_vault_id: customer_result.customer_vault_id)
      end
    end
  end
end
