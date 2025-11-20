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
    match_requests_on: [:method, :nmi_matcher]
  }

  # Custom matcher ignoring dynamic/filtered parameters
  config.register_request_matcher :nmi_matcher do |r1, r2|
    u1, u2 = URI.parse(r1.uri), URI.parse(r2.uri)
    next false unless u1.scheme == u2.scheme && u1.host == u2.host && u1.path == u2.path

    p1 = URI.decode_www_form(u1.query || '').to_h
    p2 = URI.decode_www_form(u2.query || '').to_h

    # Ignore params that are filtered or dynamic
    %w[security_key customer_vault_id subscription_id transactionid billing_id].each do |k|
      p1.delete(k)
      p2.delete(k)
    end

    p1 == p2
  end

  # Filter sensitive data from both URI (query params) and request body
  # The regex captures the value after "security_key=" and match[:value] extracts it
  config.filter_sensitive_data('<NMI_SECURITY_KEY>') do |interaction|
    uri_match = interaction.request.uri.to_s.match(/security_key=(?<value>[^&]+)/)
    body_match = interaction.request.body&.match(/security_key=(?<value>[^&]+)/)

    uri_match ? uri_match[:value] : body_match&.[](:value)
  end

  # Filter credit card numbers
  config.filter_sensitive_data('<CREDIT_CARD>') do |interaction|
    uri_match = interaction.request.uri.to_s.match(/ccnumber=(?<value>\d+)/)
    body_match = interaction.request.body&.match(/ccnumber=(?<value>\d+)/)

    uri_match ? uri_match[:value] : body_match&.[](:value)
  end

  # Filter CVV
  config.filter_sensitive_data('<CVV>') do |interaction|
    uri_match = interaction.request.uri.to_s.match(/cvv=(?<value>\d+)/)
    body_match = interaction.request.body&.match(/cvv=(?<value>\d+)/)

    uri_match ? uri_match[:value] : body_match&.[](:value)
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
