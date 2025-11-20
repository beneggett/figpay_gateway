require 'test_helper'

describe 'Configuration' do
  after do
    # Reset configuration after each test
    NMIGateway.instance_variable_set(:@configuration, nil)
  end

  describe 'NMIGateway.configuration' do
    it 'returns a Configuration instance' do
      assert_instance_of NMIGateway::Configuration, NMIGateway.configuration
    end

    it 'returns the same instance on multiple calls' do
      config1 = NMIGateway.configuration
      config2 = NMIGateway.configuration
      assert_same config1, config2
    end
  end

  describe 'NMIGateway.configure' do
    it 'yields the configuration instance' do
      NMIGateway.configure do |config|
        assert_instance_of NMIGateway::Configuration, config
      end
    end

    it 'sets security_key' do
      NMIGateway.configure do |config|
        config.security_key = 'test_key_123'
      end

      assert_equal 'test_key_123', NMIGateway.configuration.security_key
    end

    it 'sets transaction_url' do
      custom_url = 'https://custom.gateway.com/api/transact.php'
      NMIGateway.configure do |config|
        config.transaction_url = custom_url
      end

      assert_equal custom_url, NMIGateway.configuration.transaction_url
    end

    it 'sets query_url' do
      custom_url = 'https://custom.gateway.com/api/query.php'
      NMIGateway.configure do |config|
        config.query_url = custom_url
      end

      assert_equal custom_url, NMIGateway.configuration.query_url
    end

    it 'sets test_mode' do
      NMIGateway.configure do |config|
        config.test_mode = '1'
      end

      assert_equal '1', NMIGateway.configuration.test_mode
    end
  end

  describe 'FigpayGateway.configuration' do
    it 'returns the same configuration as NMIGateway' do
      assert_same NMIGateway.configuration, FigpayGateway.configuration
    end
  end

  describe 'FigpayGateway.configure' do
    it 'configures NMIGateway' do
      FigpayGateway.configure do |config|
        config.security_key = 'figpay_key_456'
      end

      assert_equal 'figpay_key_456', NMIGateway.configuration.security_key
      assert_equal 'figpay_key_456', FigpayGateway.configuration.security_key
    end
  end

  describe 'NMIGateway::Configuration' do
    it 'uses default URLs when not configured' do
      config = NMIGateway::Configuration.new

      assert_equal 'https://figpay.transactiongateway.com/api/transact.php', config.transaction_url
      assert_equal 'https://figpay.transactiongateway.com/api/query.php', config.query_url
    end

    it 'falls back to environment variables' do
      # Set temporary environment variables
      original_key = ENV['NMI_SECURITY_KEY']
      original_test_mode = ENV['NMI_TEST_MODE']

      ENV['NMI_SECURITY_KEY'] = 'env_key_789'
      ENV['NMI_TEST_MODE'] = '1'

      config = NMIGateway::Configuration.new

      assert_equal 'env_key_789', config.security_key
      assert_equal '1', config.test_mode

      # Restore original values
      ENV['NMI_SECURITY_KEY'] = original_key
      ENV['NMI_TEST_MODE'] = original_test_mode
    end

    it 'prefers explicit options over environment variables' do
      original_key = ENV['NMI_SECURITY_KEY']
      ENV['NMI_SECURITY_KEY'] = 'env_key'

      config = NMIGateway::Configuration.new(security_key: 'explicit_key')

      assert_equal 'explicit_key', config.security_key

      ENV['NMI_SECURITY_KEY'] = original_key
    end
  end

  describe 'NMIGateway::Api with configuration' do
    it 'uses configured security_key' do
      NMIGateway.configure do |config|
        config.security_key = 'api_test_key'
      end

      api = NMIGateway::Api.new
      assert_equal 'api_test_key', api.security_key
    end

    it 'uses configured URLs' do
      custom_transaction_url = 'https://custom1.com/transact.php'
      custom_query_url = 'https://custom1.com/query.php'

      NMIGateway.configure do |config|
        config.transaction_url = custom_transaction_url
        config.query_url = custom_query_url
      end

      api = NMIGateway::Api.new
      assert_equal custom_transaction_url, api.transaction_url
      assert_equal custom_query_url, api.query_url
    end

    it 'allows security_key override via options' do
      NMIGateway.configure do |config|
        config.security_key = 'config_key'
      end

      api = NMIGateway::Api.new(security_key: 'override_key')
      assert_equal 'override_key', api.security_key
    end

    it 'uses configured test_mode in credentials' do
      NMIGateway.configure do |config|
        config.security_key = 'test_key'
        config.test_mode = '1'
      end

      api = NMIGateway::Api.new
      credentials = api.send(:credentials)

      assert_equal 'test_key', credentials[:security_key]
      assert_equal '1', credentials[:test_mode]
    end
  end

  describe 'FigpayGateway::Transaction with configuration' do
    it 'uses configured settings' do
      FigpayGateway.configure do |config|
        config.security_key = 'transaction_key'
      end

      transaction = FigpayGateway::Transaction.new
      assert_equal 'transaction_key', transaction.security_key
    end
  end
end
