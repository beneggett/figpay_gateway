module NMIGateway
  class CustomerVault < Api

    # NMIGateway::CustomerVault.new.create ccnumber: '4111111111111111', ccexp: "0219", first_name: "John", last_name: "Doe"
    def create(options = {})
      query = set_query(options)
      query[:customer_vault] = 'add_customer'

      require_fields(:ccnumber, :ccexp)
      post query
    end

    # NMIGateway::CustomerVault.new.update customer_vault_id: 481397475, ccnumber: '4111111111111111', ccexp: "0220", first_name: "Jane", last_name: "Doe"
    def update(options = {})
      query = set_query(options)
      query[:customer_vault] = 'update_customer'
      require_fields(:customer_vault_id)
      post query
    end

    # NMIGateway::CustomerVault.new.destroy customer_vault_id: 481397475
    def destroy(options = {})
      query = set_query(options)
      query[:customer_vault] = 'delete_customer'
      require_fields(:customer_vault_id)
      post query
    end

    # NMIGateway::CustomerVault.new.find customer_vault_id: 481397475
    def find(options = {})
      query = set_query(options)
      query[:report_type] = 'customer_vault'
      require_fields(:customer_vault_id)
      get query
    end

  end
end
