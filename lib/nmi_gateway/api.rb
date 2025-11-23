module NMIGateway
  class Api
    include HTTParty

    attr_accessor :security_key, :query, :configuration

    def initialize(options = {}, configuration = NMIGateway.configuration)
      @configuration = configuration
      @security_key = options[:security_key] || configuration.security_key
    end

    def transaction_url
      @configuration.transaction_url
    end

    def query_url
      @configuration.query_url
    end

    def get(options={})
      response = self.class.get(query_url, query: options.merge(credentials), timeout: 30, headers: headers)
      api_type = options[:type] || options[:report_type]
      handle_response(response, api_type)
    end

    def post(options={})
      response = self.class.get(transaction_url, query: options.merge(credentials), timeout: 30, headers: headers)
      api_type = options[:type] || options[:customer_vault]
      handle_response(response, api_type)
    end

    private

    def handle_response(response, api_type)
      if response.success?
        NMIGateway::Response.new(response, api_type)
      else
        NMIGateway::Error.new(response.code, response.message, response)
      end
    end

    def headers
      {'Content-Type' => "application/xml", 'Accept' => "application/xml"}
    end

    def credentials
      creds = {security_key: security_key}
      creds[:test_mode] = configuration.test_mode if configuration.test_mode
      creds
    end

    def set_query(options = {})
      query = {}
      query[:customer_vault]               = options[:customer_vault] # add_customer or update_customer
      query[:customer_vault_id]            = options[:customer_vault_id]
      query[:transactionid]                = options[:transactionid]
      query[:billing_id]                   = options[:billing_id]

      # Query params
      query[:condition]                    = options[:condition]  # pending, pendingsettlement, failed, canceled, complete, unknown. Can be stringed together.
      query[:transaction_type]             = options[:transaction_type] # cc, ck
      query[:action_type]                  = options[:action_type] # sale, refund, credit, auth, capture, void, return

      query[:transaction_id]               = options[:transaction_id] # can me multiple together
      query[:cc_number]                    = options[:cc_number] # You can use either the full number or the last 4 digits of the credit card number.
      query[:end_date]                     = options[:end_date] # YYYYMMDDhhmmss
      query[:report_type]                  = options[:report_type] # receipt or customer_vault
      query[:mobile_device_license]        = options[:mobile_device_license]
      query[:mobile_device_nickname]       = options[:mobile_device_nickname]


      # Credit Cards
      query[:ccnumber]                     = options[:ccnumber]
      query[:ccexp]                        = options[:ccexp] # FORMAT MMYY
      query[:cvv]                          = options[:cvv] # Recommended

      # Payment Token
      query[:payment_token]                = options[:payment_token] # from Collect.js

      # Payment
      query[:amount]                       = options[:amount]
      query[:currency]                     = options[:currency] || 'USD'
      query[:payment]                      = options[:payment] || 'creditcard' # creditcard or check
      query[:processor_id]                 = options[:processor_id]
      query[:dup_seconds]                  = options[:dup_seconds]
      query[:billing_method]               = options[:billing_method] # recurring
      query[:customer_receipt]             = options[:customer_receipt] # true, false

      # Advanced Payment
      query[:tax]                          = options[:tax]
      query[:shipping]                     = options[:shipping]

      # Recurring Billing
      query[:recurring]                    = options[:recurring ] # add_subscription
      query[:plan_id]                      = options [:plan_id]
      query[:current_plan_id]              = options [:current_plan_id] # identifies plan when editing
      query[:plan_name]                    = options [:plan_name]
      query[:plan_payments]                = options [:plan_payments] # 0 until canceled
      query[:plan_amount]                  = options [:plan_amount]
      query[:day_frequency]                = options [:day_frequency]
      query[:month_frequency]              = options [:month_frequency] # 1-24
      query[:day_of_month]                 = options [:day_of_month] # 1-31
      query[:start_date]                   = options [:start_date] #YYYYMMDD
      query[:subscription_id]              = options [:subscription_id]


      # Customer Billing
      query[:first_name]                   = options[:first_name]
      query[:last_name]                    = options[:last_name]
      query[:company]                      = options[:company]
      query[:address1]                     = options[:address1]
      query[:address2]                     = options[:address2]
      query[:city]                         = options[:city]
      query[:state]                        = options[:state]
      query[:zip]                          = options[:zip]
      query[:country]                      = options[:country]
      query[:phone]                        = options[:phone]
      query[:fax]                          = options[:fax]
      query[:email]                        = options[:email]
      query[:ipaddress]                    = options[:ipaddress] # Recommended

      # Additional Customer Info
      query[:social_security_number]       = options[:social_security_number]
      query[:drivers_license_number]       = options[:drivers_license_number]
      query[:drivers_license_dob]          = options[:drivers_license_dob]
      query[:drivers_license_state]        = options[:drivers_license_state]

      # Customer Shipping
      query[:shipping_id]                  = options[:shipping_id]
      query[:shipping_first_name]          = options[:shipping_first_name]
      query[:shipping_last_name]           = options[:shipping_last_name]
      query[:shipping_company]             = options[:shipping_company]
      query[:shipping_address1]            = options[:shipping_address1]
      query[:shipping_address2]            = options[:shipping_address2]
      query[:shipping_city]                = options[:shipping_city]
      query[:shipping_state]               = options[:shipping_state]
      query[:shipping_zip]                 = options[:shipping_zip]
      query[:shipping_country]             = options[:shipping_country]
      query[:shipping_phone]               = options[:shipping_phone]
      query[:shipping_fax]                 = options[:shipping_fax]
      query[:shipping_email]               = options[:shipping_email]

      # For ACH
      query[:checkname]                    = options[:check_name]
      query[:checkaba]                     = options[:check_routing_number] # routing_number
      query[:checkaccount]                 = options[:check_account_number]
      query[:account_holder_type]          = options[:account_holder_type] # personal or 'business'
      query[:account_type]                 = options[:account_type]  # checking or savings
      query[:sec_code]                     = options[:sec_code] #  'PPD', 'WEB', 'TEL', or 'CCD'

      # Optional order fields
      query[:orderid]                      = options[:orderid]
      query[:order_description]            = options[:order_description]
      query[:order_date]                   = options[:order_date]
      query[:ponumber]                     = options[:ponumber]
      query[:tracking_number]              = options[:tracking_number]

      # order update fields
      query[:shipping_carrier]             = options[:shipping_carrier] #  ups, fedex, dhl, or usps
      query[:shipping_postal]              = options[:shipping_postal]
      query[:ship_from_postal]             = options[:ship_from_postal]
      query[:shipping_date]                = options[:shipping_date]
      query[:summary_commodity_code]       = options[:summary_commodity_code]
      query[:duty_amount]                  = options[:duty_amount]
      query[:discount_amount]              = options[:discount_amount]
      query[:tax]                          = options[:tax]
      query[:national_tax_amount]          = options[:national_tax_amount]
      query[:alternate_tax_amount]         = options[:alternate_tax_amount]
      query[:alternate_tax_id]             = options[:alternate_tax_id]
      query[:vat_tax_amount]               = options[:vat_tax_amount]
      query[:vat_tax_rate]                 = options[:vat_tax_rate]  #  1% = 1.00.
      query[:vat_invoice_reference_number] = options[:vat_invoice_reference_number]
      query[:merchant_vat_registration]    = options[:merchant_vat_registration]
      # merchant_defined_field_#  Merchant Defined Fields.



      # Descriptor fields
      query[:descriptor]                   = options[:descriptor]
      query[:descriptor_phone]             = options[:descriptor_phone]
      query[:descriptor_address]           = options[:descriptor_address]
      query[:descriptor_city]              = options[:descriptor_city]
      query[:descriptor_state]             = options[:descriptor_state]
      query[:descriptor_postal]            = options[:descriptor_postal]
      query[:descriptor_country]           = options[:descriptor_country]
      query[:descriptor_mcc]               = options[:descriptor_mcc]
      query[:descriptor_merchant_id]       = options[:descriptor_merchant_id]
      query[:descriptor_url]               = options[:descriptor_url]

      1..20.to_a.each do |i|
        query["merchant_defined_field_#{i}".to_sym] = options["merchant_defined_field_#{i}".to_sym]
      end if options.select {|k,v| k.to_s.starts_with? 'merchant_defined_field' }.any?

      @query = query.select {|k,v| !v.nil?}

    end

    def require_fields(*fields)
      if query.values_at(*fields).include?(nil)
        missing_fields = fields - query.keys
        raise Error::MissingParameters.new("Missing required keys: #{missing_fields.to_s.gsub(']', '').gsub('[', '')}") if missing_fields.any?
      end
    end
  end
end

