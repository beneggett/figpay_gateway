module NMIGateway
  class Response

    attr_accessor  :response, :success, :code, :api_type, :transactions, :customers, :response_text, :response_message, :customer_vault_id, :subscription_id, :plan_id, :plan_amount, :orderid, :transactionid, :authcode, :response_code, :avs_response_code, :cvv_response_code, :response_code_message, :avs_response_code_message, :cvv_response_code_message

    def initialize(response, api_type)
      @response = response
      @code = response.code
      @api_type = api_type
      @success = response.success?
      send "set_#{api_type}"
    end

    def set_
      parsed_response
      binding.pry
    end

    def success?
      !!success
    end

    private

    def parsed_response
      if response.body.is_a?(String)
        if response.body.include?('xml')
          Hash.from_xml response.body
        else
          parsed = CGI.parse(response.body)
          @response_message = responses[parsed['response'].first]
          @success = parsed['response'].first == '1'
          @response_text = parsed['responsetext'].first
          @response_code = parsed['response_code'].first if parsed['response_code'].first.present?
          @authcode = parsed['authcode'].first if parsed['authcode'].first.present?
          @customer_vault_id = parsed['customer_vault_id'].first if parsed['customer_vault_id'].first.present?
          @plan_id = parsed['plan_id'].first if parsed['plan_id'].first.present?
          @plan_amount = parsed['plan_amount'].first if parsed['plan_amount'].first.present?
          @subscription_id = parsed['subscription_id'].first if parsed['subscription_id'].first.present?
          @orderid = parsed['orderid'].first if parsed['orderid'].first.present?
          @transactionid = parsed['transactionid'].first if parsed['transactionid'].first.present?
          @avs_response_code = parsed['avsresponse'].first if parsed['avsresponse']&.first.present?
          @cvv_response_code = parsed['cvvresponse'].first if parsed['cvvresponse']&.first.present?
          @response_code_message = response_codes.dig(response_code) if response_code.present?
          @avs_response_code_message = avs_response_codes.dig(avs_response_code) if avs_response_code.present?
          @cvv_response_code_message = cvv_response_codes.dig(cvv_response_code) if cvv_response_code.present?
          parsed
        end
      else
        response
      end
    end


    def set_transaction
      parsed_response
      if parsed_response && parsed_response['nm_response'].present? && parsed_response['nm_response']['transaction'].present?
        transactions = parsed_response['nm_response']['transaction']
        if transactions.is_a?(Hash)
          @transactions = [ NMIGateway::Result::Transaction.new( transactions ) ]
        elsif transactions.is_a?(Array)
          @transactions = transactions.map {|c| NMIGateway::Result::Transaction.new( c ) }
        end
      else
        self
      end
    end
    alias_method :set_sale, :set_transaction
    alias_method :set_auth, :set_transaction
    alias_method :set_credit, :set_transaction
    alias_method :set_validate, :set_transaction
    alias_method :set_capture, :set_transaction
    alias_method :set_void, :set_transaction
    alias_method :set_refund, :set_transaction
    alias_method :set_update, :set_transaction

    def set_customer
      parsed_response
    end
    alias_method :set_add_customer, :set_customer
    alias_method :set_update_customer, :set_customer
    alias_method :set_delete_customer, :set_customer

    # def set_receipt
    #   parsed_response
    # end

    def set_recurring
      parsed_response
    end

    def set_customer_vault
      parsed_response
      if parsed_response && parsed_response['nm_response'] && parsed_response['nm_response']['customer_vault'] && customers = parsed_response['nm_response']['customer_vault']['customer']
        if customers.is_a?(Hash)
          @customers = [ NMIGateway::Result::Customer.new( customers ) ]
        elsif customers.is_a?(Array)
          @customers = customers.map {|c| NMIGateway::Result::Customer.new( c ) }
        end
      end
    end

    def responses
      {"1" => "Transaction Approved", "2" => "Transaction Declined", "3" => "Error in transaction data or system error"}
    end

    def response_codes
      {
        "100" => "Transaction was approved.",
        "200" => "Transaction was declined by processor.",
        "201" => "Do not honor.",
        "202" => "Insufficient funds.",
        "203" => "Over limit.",
        "204" => "Transaction not allowed.",
        "220" => "Incorrect payment information.",
        "221" => "No such card issuer.",
        "222" => "No card number on file with issuer.",
        "223" => "Expired card.",
        "224" => "Invalid expiration date.",
        "225" => "Invalid card security code.",
        "240" => "Call issuer for further information.",
        "250" => "Pick up card.",
        "251" => "Lost card.",
        "252" => "Stolen card.",
        "253" => "Fraudulent card.",
        "260" => "Declined with further instructions available. (See response text)",
        "261" => "Declined-Stop all recurring payments.",
        "262" => "Declined-Stop this recurring program.",
        "263" => "Declined-Update cardholder data available.",
        "264" => "Declined-Retry in a few days.",
        "300" => "Transaction was rejected by gateway.",
        "400" => "Transaction error returned by processor.",
        "410" => "Invalid merchant configuration.",
        "411" => "Merchant account is inactive.",
        "420" => "Communication error.",
        "421" => "Communication error with issuer.",
        "430" => "Duplicate transaction at processor.",
        "440" => "Processor format error.",
        "441" => "Invalid transaction information.",
        "460" => "Processor feature not available.",
        "461" => "Unsupported card type."
      }
    end

    def avs_response_codes
      {
        "X" => "Exact match, 9-character numeric ZIP",
        "Y" => "Exact match, 5-character numeric ZIP",
        "D" => "Exact match, 5-character numeric ZIP",
        "M" => "Exact match, 5-character numeric ZIP",
        "A" => "Address match only",
        "B" => "Address match only",
        "W" => "9-character numeric ZIP match only",
        "Z" => "5-character ZIP match only",
        "P" => "5-character ZIP match only",
        "L" => "5-character ZIP match only",
        "N" => "No address or ZIP match only",
        "C" => "No address or ZIP match only",
        "U" => "Address unavailable",
        "G" => "Non-U.S. issuer does not participate",
        "I" => "Non-U.S. issuer does not participate",
        "R" => "Issuer system unavailable",
        "E" => "Not a mail/phone order",
        "S" => "Service not supported",
        "O" => "AVS not available"
      }
    end

    def cvv_response_codes
      {
        "M" => "CVV2/CVC2 match",
        "N" => "CVV2/CVC2 no match",
        "P" => "Not processed",
        "S" => "Merchant has indicated that CVV2/CVC2 is not present on card",
        "U" => "Issuer is not certified and/or has not provided Visa encryption keys"
      }
    end

  end
end
