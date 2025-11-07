$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'figpay_gateway'

require 'minitest/autorun'
require 'minitest/spec'
require 'vcr'
require 'webmock/minitest'
require 'dotenv'
require_relative 'fixtures'

# Load environment variables
Dotenv.load

# Use demo credentials if not set (for VCR recording)
ENV['NMI_SECURITY_KEY'] = '6457Thfj624V5r7WUwc5v6a68Zsd6YEm'
ENV['NMI_TEST_MODE'] = 'enabled'

# VCR Configuration
VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: [:method, :uri, :body]
  }

  # Filter sensitive data
  config.filter_sensitive_data('<NMI_SECURITY_KEY>') do |interaction|
    # Filter security key from request body
    if interaction.request.body
      match = interaction.request.body.match(/security_key=([^&]+)/)
      match[1] if match
    end
  end

  # Filter credit card numbers
  config.filter_sensitive_data('<CREDIT_CARD>') do |interaction|
    if interaction.request.body
      match = interaction.request.body.match(/ccnumber=(\d+)/)
      match[1] if match
    end
  end

  # Filter CVV
  config.filter_sensitive_data('<CVV>') do |interaction|
    if interaction.request.body
      match = interaction.request.body.match(/cvv=(\d+)/)
      match[1] if match
    end
  end

  # Also filter from response bodies
  config.before_record do |interaction|
    # Filter card numbers in responses (typically last 4 digits shown as XXXX1111)
    if interaction.response.body
      interaction.response.body.gsub!(/\d{16}/, '<CREDIT_CARD>')
      interaction.response.body.gsub!(/ccnumber=\d+/, 'ccnumber=<CREDIT_CARD>')
    end
  end
end

# Helper module for tests
module TestHelpers
  def with_vcr_cassette(cassette_name, &block)
    VCR.use_cassette(cassette_name, &block)
  end
end

# Include helper in all specs
class Minitest::Spec
  include TestHelpers
end
