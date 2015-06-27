module MercadoPago
  
  module Balance

    def self.get_client_balance(access_token)
      response = MercadoPago::Request.wrap_get("/users/me?access_token=#{access_token}")
      user_id = response['id']
      payload = { access_token: access_token }
      headers = { accept: 'application/json' }
      MercadoPago::Request.make_request(:get, "/users/#{user_id}/mercadopago_account/balance", payload, headers)
    end

  end

end