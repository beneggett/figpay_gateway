module NMIGateway
  class Error
    class AuthenticationError < StandardError; end
    class NoApiKey < AuthenticationError; end
    class InvalidResponseFormat < TypeError; end
    class MissingParameters < TypeError; end
    class Timeout < Timeout::Error ; end
    class NoData < EOFError; end

    attr_reader :message, :code, :response

    def initialize( code, message, response)
      @code = response_code
      @message = response_message
      @response = response
    end

  end
end

