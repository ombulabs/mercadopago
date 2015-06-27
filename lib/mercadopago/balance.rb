module MercadoPago

  #
  # Retrieves account balance for a given user (whose access_token is required).
  # Expected response is
  # {
  #     "user_id"=>123123,
  #     "total_amount"=>0,
  #     "available_balance"=>0,
  #     "unavailable_balance"=>0,
  #     "unavailable_balance_by_reason"=>[
  #         {
  #             "reason"=>"dispute",
  #             "amount"=>0
  #         },
  #         {
  #             "reason"=>"fraud",
  #             "amount"=>0
  #         },
  #         {
  #             "reason"=>"ml_debt",
  #             "amount"=>0
  #         },
  #         {
  #             "reason"=>"time_period",
  #             "amount"=>0
  #         },
  #         {
  #             "reason"=>"restriction",
  #             "amount"=>0
  #         }
  #     ],
  #     "available_balance_by_transaction_type"=>[
  #         {
  #             "amount"=>0,
  #             "transaction_type"=>"transfer"
  #         },
  #         {
  #             "amount"=>0,
  #             "transaction_type"=>"withdrawal"
  #         },
  #         {
  #             "amount"=>0,
  #             "transaction_type"=>"payment"
  #         }
  #     ],
  #     "currency_id"=>""
  # }
  #
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