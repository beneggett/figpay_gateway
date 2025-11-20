require "rubygems"
require "active_support/all"
require "httparty"
require "ostruct"

require "figpay_gateway/version"

require "nmi_gateway/configuration"
require "nmi_gateway/api"
require "nmi_gateway/data"
require "nmi_gateway/result/action"
require "nmi_gateway/result/transaction"
require "nmi_gateway/result/customer"
require "nmi_gateway/customer_vault"

require "nmi_gateway/error"
require "nmi_gateway/recurring"
require "nmi_gateway/response"
require "nmi_gateway/transaction"

module NMIGateway
  class << self
    attr_writer :configuration
  end

  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= NMIGateway::Configuration.new
  end
end

module FigpayGateway
  # Expose NMIGateway classes under the FigpayGateway namespace
  Api = NMIGateway::Api
  Transaction = NMIGateway::Transaction
  CustomerVault = NMIGateway::CustomerVault
  Recurring = NMIGateway::Recurring
  Response = NMIGateway::Response
  Error = NMIGateway::Error
  Data = NMIGateway::Data
end
