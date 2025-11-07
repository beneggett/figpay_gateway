module NMIGateway
  class Transaction < Api

    # NMIGateway::Transaction.new.sale ccnumber: '4111111111111111', ccexp: "0219", first_name: "John", last_name: "Doe", amount: 22.30, email: "john@doe.com", country: "US"
    # NMIGateway::Transaction.new.sale payment_token: 'abc123', first_name: "John", last_name: "Doe", amount: 22.30, email: "john@doe.com", country: "US"
    # NMIGateway::Transaction.new.sale customer_vault_id: '123456789', amount: 22.30
    def sale(options = {})
      query = set_query(options)
      query[:type] = 'sale'
      if query[:customer_vault_id]
        require_fields(:customer_vault_id, :amount)
      elsif query[:payment_token]
        require_fields(:payment_token, :first_name, :last_name, :email, :amount)
      else
        require_fields(:ccnumber, :ccexp, :first_name, :last_name, :email, :amount)
      end
      post query
    end

    # NMIGateway::Transaction.new.authorize ccnumber: '4111111111111111', ccexp: "0219", first_name: "John", last_name: "Doe", amount: 22.25, email: "john@doe.com", country: "US"
    # NMIGateway::Transaction.new.authorize payment_token: 'abc123', first_name: "John", last_name: "Doe", amount: 22.25, email: "john@doe.com", country: "US"
    # NMIGateway::Transaction.new.authorize customer_vault_id: '123456789', amount: 22.25
    def authorize(options = {})
      query = set_query(options)
      query[:type] = 'auth'
      if query[:customer_vault_id]
        require_fields(:customer_vault_id, :amount)
      elsif query[:payment_token]
        require_fields(:payment_token, :first_name, :last_name, :email, :amount)
      else
        require_fields(:ccnumber, :ccexp, :first_name, :last_name, :email, :amount)
      end
      post query
    end

    # NMIGateway::Transaction.new.capture transactionid: 3261830498, amount: 22.30
    def capture(options = {})
      query = set_query(options)
      query[:type] = 'capture'
      require_fields(:transactionid, :amount )
      post query
    end

    # NMIGateway::Transaction.new.void transactionid: 3261830498, amount: 22.30
    def void(options = {})
      query = set_query(options)
      query[:type] = 'void'
      require_fields(:transactionid)
      post query
    end

    # NMIGateway::Transaction.new.refund transactionid: 3261844010, amount: 5
    def refund(options = {})
      query = set_query(options)
      query[:type] = 'refund'
      require_fields(:transactionid) # amount
      post query
    end

    # NMIGateway::Transaction.new.update transactionid: 3261844010, first_name: "joe"
    def update(options = {})
      query = set_query(options)
      query[:type] = 'update'
      require_fields(:transactionid)
      post query
    end

    # NMIGateway::Transaction.new.find transaction_id: 3261844010
    def find(options = {})
      query = set_query(options)
      query[:report_type] ||= 'transaction'
      get query
    end

    # Disabled for our merchant account
    # NMIGateway::Transaction.new.credit ccnumber: '4111111111111111', ccexp: "0219", first_name: "John", last_name: "Doe", amount: 22.30, email: "john@doe.com", country: "US"
    # NMIGateway::Transaction.new.credit payment_token: 'abc123', first_name: "John", last_name: "Doe", amount: 22.30, email: "john@doe.com", country: "US"
    # NMIGateway::Transaction.new.credit customer_vault_id: '123456789', amount: 22.30
    def credit(options = {})
      query = set_query(options)
      query[:type] = 'credit'
      if query[:customer_vault_id]
        require_fields(:customer_vault_id, :amount)
      elsif query[:payment_token]
        require_fields(:payment_token, :first_name, :last_name, :email, :amount)
      else
        require_fields(:ccnumber, :ccexp, :first_name, :last_name, :email, :amount)
      end
      post query
    end

    # Disabled for our merchant account
    # NMIGateway::Transaction.new.validate ccnumber: '4111111111111111', ccexp: "0219", first_name: "John", last_name: "Doe", email: "john@doe.com", country: "US"
    # NMIGateway::Transaction.new.validate payment_token: 'abc123', first_name: "John", last_name: "Doe", email: "john@doe.com", country: "US"
    # NMIGateway::Transaction.new.validate customer_vault_id: '123456789'
    def validate(options = {})
      query = set_query(options)
      query[:type] = 'validate'
      if query[:customer_vault_id]
        require_fields(:customer_vault_id)
      elsif query[:payment_token]
        require_fields(:payment_token, :first_name, :last_name, :email)
      else
        require_fields(:ccnumber, :ccexp, :first_name, :last_name, :email)
      end
      post query
    end

  end
end
