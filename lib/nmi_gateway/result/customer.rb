module NMIGateway
  module Result
    class Customer < Data

      attr_accessor :id, :first_name, :last_name, :address_1, :address_2, :company, :city, :state, :postal_code, :country, :email, :phone, :fax, :cell_phone, :customertaxid, :website, :shipping_first_name, :shipping_last_name, :shipping_address_1, :shipping_address_2, :shipping_company, :shipping_city, :shipping_state, :shipping_postal_code, :shipping_country, :shipping_email, :shipping_carrier, :tracking_number, :shipping_date, :shipping, :cc_number, :cc_hash, :cc_exp, :cc_start_date, :cc_issue_number, :check_account, :check_hash, :check_aba, :check_name, :account_holder_type, :account_type, :sec_code, :processor_id, :cc_bin, :customer_vault_id


      def initialize(customer)
        set_attributes(customer)
      end

      private
      def set_attributes(customer)
        @id                   = customer["id"]
        @first_name           = customer["first_name"]
        @last_name            = customer["last_name"]
        @address_1            = customer["address_1"]
        @address_2            = customer["address_2"]
        @company              = customer["company"]
        @city                 = customer["city"]
        @state                = customer["state"]
        @postal_code          = customer["postal_code"]
        @country              = customer["country"]
        @email                = customer["email"]
        @phone                = customer["phone"]
        @fax                  = customer["fax"]
        @cell_phone           = customer["cell_phone"]
        @customertaxid        = customer["customertaxid"]
        @website              = customer["website"]
        @shipping_first_name  = customer["shipping_first_name"]
        @shipping_last_name   = customer["shipping_last_name"]
        @shipping_address_1   = customer["shipping_address_1"]
        @shipping_address_2   = customer["shipping_address_2"]
        @shipping_company     = customer["shipping_company"]
        @shipping_city        = customer["shipping_city"]
        @shipping_state       = customer["shipping_state"]
        @shipping_postal_code = customer["shipping_postal_code"]
        @shipping_country     = customer["shipping_country"]
        @shipping_email       = customer["shipping_email"]
        @shipping_carrier     = customer["shipping_carrier"]
        @tracking_number      = customer["tracking_number"]
        @shipping_date        = customer["shipping_date"]
        @shipping             = customer["shipping"]
        @cc_number            = customer["cc_number"]
        @cc_hash              = customer["cc_hash"]
        @cc_exp               = customer["cc_exp"]
        @cc_start_date        = customer["cc_start_date"]
        @cc_issue_number      = customer["cc_issue_number"]
        @check_account        = customer["check_account"]
        @check_hash           = customer["check_hash"]
        @check_aba            = customer["check_aba"]
        @check_name           = customer["check_name"]
        @account_holder_type  = customer["account_holder_type"]
        @account_type         = customer["account_type"]
        @sec_code             = customer["sec_code"]
        @processor_id         = customer["processor_id"]
        @cc_bin               = customer["cc_bin"]
        @customer_vault_id    = customer["customer_vault_id"]
      end

    end
  end
end
