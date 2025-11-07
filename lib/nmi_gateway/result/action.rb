module NMIGateway
  module Result
    class Action < Data

      attr_accessor :amount, :action_type, :date, :success, :ip_address, :source, :username, :response_text, :batch_id, :processor_batch_id, :response_code, :processor_response_text, :processor_response_code, :device_license_number, :device_nickname

      attr_accessor

      def initialize(action)
        set_attributes(action)
        $actions ||= []
        $actions << action.keys
      end

      private

      def set_attributes(action)
        @amount                  = action["amount"]
        @action_type             = action["action_type"]
        @date                    = action["date"]
        @success                 = action["success"]
        @ip_address              = action["ip_address"]
        @source                  = action["source"]
        @username                = action["username"]
        @response_text           = action["response_text"]
        @batch_id                = action["batch_id"]
        @processor_batch_id      = action["processor_batch_id"]
        @response_code           = action["response_code"]
        @processor_response_text = action["processor_response_text"]
        @processor_response_code = action["processor_response_code"]
        @device_license_number   = action["device_license_number"]
        @device_nickname         = action["device_nickname"]

      end

    end
  end
end
