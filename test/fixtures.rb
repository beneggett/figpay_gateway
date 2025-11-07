module Fixtures
  # Test credit card data (NMI test cards)
  VALID_VISA = {
    ccnumber: '4111111111111111',
    ccexp: '1225',
    cvv: '999'
  }.freeze

  VALID_MASTERCARD = {
    ccnumber: '5499740000000057',
    ccexp: '1225',
    cvv: '998'
  }.freeze

  # Customer billing information
  BILLING_INFO = {
    first_name: 'John',
    last_name: 'Doe',
    address1: '123 Main St',
    city: 'Beverly Hills',
    state: 'CA',
    zip: '90210',
    country: 'US',
    email: 'john@example.com',
    phone: '555-555-5555'
  }.freeze

  BILLING_INFO_ALT = {
    first_name: 'Jane',
    last_name: 'Smith',
    address1: '456 Oak Ave',
    city: 'Los Angeles',
    state: 'CA',
    zip: '90001',
    country: 'US',
    email: 'jane@example.com',
    phone: '555-555-1234'
  }.freeze

  # Transaction amounts
  AMOUNTS = {
    small: 10.00,
    medium: 25.00,
    large: 100.00,
    refund: 5.00,
    void: 1.00,
    subscription: 29.99
  }.freeze

  # Helper methods
  def self.card_with_billing(card_type = :visa)
    card = card_type == :visa ? VALID_VISA : VALID_MASTERCARD
    card.merge(BILLING_INFO)
  end

  def self.alt_card_with_billing(card_type = :visa)
    card = card_type == :visa ? VALID_VISA : VALID_MASTERCARD
    card.merge(BILLING_INFO_ALT)
  end

  def self.minimal_card_data
    VALID_VISA.merge(
      first_name: 'John',
      last_name: 'Doe',
      email: 'john@example.com'
    )
  end

  def self.plan_data(suffix = nil)
    timestamp = Time.now.to_f.to_s.gsub('.', '')
    {
      plan_id: "test-plan-#{suffix}-#{timestamp}",
      plan_name: 'Test Monthly Plan',
      plan_amount: AMOUNTS[:subscription],
      month_frequency: 1,
      day_of_month: 1
    }
  end
end
