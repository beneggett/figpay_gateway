

module NMIGateway
  module Result
    class Transaction < Data

      attr_accessor :transaction_id, :partial_payment_id, :partial_payment_balance, :platform_id, :transaction_type, :condition, :order_id, :authorization_code, :ponumber, :order_description, :first_name, :last_name, :address_1, :address_2, :company, :city, :state, :postal_code, :country, :email, :phone, :fax, :cell_phone, :customertaxid, :customerid, :website, :shipping_first_name, :shipping_last_name, :shipping_address_1, :shipping_address_2, :shipping_company, :shipping_city, :shipping_state, :shipping_postal_code, :shipping_country, :shipping_email, :shipping_carrier, :tracking_number, :shipping_date, :shipping, :shipping_phone, :cc_number, :cc_hash, :cc_exp, :cavv, :actions

      def initialize(transaction)
        set_attributes(transaction)
      end

      private

      def set_attributes(transaction)
        @transaction_id          = transaction["transaction_id"]
        @partial_payment_id      = transaction["partial_payment_id"]
        @partial_payment_balance = transaction["partial_payment_balance"]
        @platform_id             = transaction["platform_id"]
        @transaction_type        = transaction["transaction_type"]
        @condition               = transaction["condition"]
        @order_id                = transaction["order_id"]
        @authorization_code      = transaction["authorization_code"]
        @ponumber                = transaction["ponumber"]
        @order_description       = transaction["order_description"]
        @first_name              = transaction["first_name"]
        @last_name               = transaction["last_name"]
        @address_1               = transaction["address_1"]
        @address_2               = transaction["address_2"]
        @company                 = transaction["company"]
        @city                    = transaction["city"]
        @state                   = transaction["state"]
        @postal_code             = transaction["postal_code"]
        @country                 = transaction["country"]
        @email                   = transaction["email"]
        @phone                   = transaction["phone"]
        @fax                     = transaction["fax"]
        @cell_phone              = transaction["cell_phone"]
        @customertaxid           = transaction["customertaxid"]
        @customerid              = transaction["customerid"]
        @website                 = transaction["website"]
        @shipping_first_name     = transaction["shipping_first_name"]
        @shipping_last_name      = transaction["shipping_last_name"]
        @shipping_address_1      = transaction["shipping_address_1"]
        @shipping_address_2      = transaction["shipping_address_2"]
        @shipping_company        = transaction["shipping_company"]
        @shipping_city           = transaction["shipping_city"]
        @shipping_state          = transaction["shipping_state"]
        @shipping_postal_code    = transaction["shipping_postal_code"]
        @shipping_country        = transaction["shipping_country"]
        @shipping_email          = transaction["shipping_email"]
        @shipping_carrier        = transaction["shipping_carrier"]
        @tracking_number         = transaction["tracking_number"]
        @shipping_date           = transaction["shipping_date"]
        @shipping                = transaction["shipping"]
        @shipping_phone          = transaction["shipping_phone"]
        @cc_number               = transaction["cc_number"]
        @cc_hash                 = transaction["cc_hash"]
        @cc_exp                  = transaction["cc_exp"]
        @cavv                    = transaction["cavv"]
        set_actions(transaction["action"])
      end

      def set_actions(actions)
        if actions.is_a?(Hash)
          @actions = [ NMIGateway::Result::Action.new( actions ) ]
        elsif actions.is_a?(Array)
          @actions = actions.map {|c| NMIGateway::Result::Action.new( c ) }
        end if actions.present?
      end

    end
  end
end
