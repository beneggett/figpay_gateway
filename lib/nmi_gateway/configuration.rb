# frozen_string_literal: true

module NMIGateway
  class Configuration
    attr_accessor :security_key, :transaction_url, :query_url, :test_mode

    def initialize(options = {})
      @security_key = options.dig(:security_key) || ENV["NMI_SECURITY_KEY"]
      @transaction_url = options.dig(:transaction_url) || ENV.fetch("NMI_TRANSACTION_URL", "https://figpay.transactiongateway.com/api/transact.php")
      @query_url = options.dig(:query_url) || ENV.fetch("NMI_QUERY_URL", "https://figpay.transactiongateway.com/api/query.php")
      @test_mode = options.dig(:test_mode) || ENV["NMI_TEST_MODE"]
    end
  end
end
