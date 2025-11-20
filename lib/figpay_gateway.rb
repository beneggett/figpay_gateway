# FigPay Gateway is a wrapper around the NMI Gateway
# This allows the gem to be portable across different NMI white-label providers
require "nmi_gateway"

module FigpayGateway
  # Alias configuration methods to NMIGateway
  def self.configure(&block)
    NMIGateway.configure(&block)
  end

  def self.configuration
    NMIGateway.configuration
  end

  def self.configuration=(config)
    NMIGateway.configuration = config
  end
end
