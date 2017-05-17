module MercadoPago

  # 
  # Retrieves information about single or multiple movements by applying different filters.
  #
  # - access_token: the user access token got after client initialization
  # - filters: hash that can filters to be applied to query. Some example of filters are
  #     
  #   type: "income"
  #   offset: "0"
  #   limit: "10"
  #   id: "movement_id"
  #   reference_id: "payment_id"
  #   user_id: "user_id"
  #   range: "date_created"
  #   begin_date: "NOW-1MONTH"
  #   end_date: "NOW"
  #   status: "available"
  #   range: "date_created"
  #   begin_date: "2012-10-21T00:00:00Z"
  #   end_date: "2012-10-25T24:00:00Z"
  #   reference_id: "reference_id"
  #   type: "movement_type"
  #   detail: "movement_detail"
  #
  # Expected result should be
  # 
  # {
  #     "paging": {
  #         "total": 70,
  #         "limit": 10,
  #         "offset": 0
  #     },
  #     "results": [
  #         {
  #             "id": MOVEMENT_ID,
  #             "user_id": 186007323,
  #             "type": "income",
  #             "detail": "payment",
  #             "amount": 425,
  #             "currency_id": "ARS",
  #             "reference_id": ASSOCIATED_REFERENCE_ID,
  #             "site_id": "MLA",
  #             "client_id": 0,
  #             "financial_entity": "credit_card",
  #             "status": "unavailable",
  #             "label": [],
  #             "date_created": "2013-09-23T12:01:30.000-04:00",
  #             "date_released": "2013-09-25T12:01:30.000-04:00",
  #             "balanced_amount": 425,
  #             "original_move_id": null
  #         },
  #         {
  #             "id":  MOVEMENT_ID,
  #             "user_id": USER_ID,
  #             "type": "expense",
  #             "detail": "payment",
  #             "amount": -125.8,
  #             "currency_id": "ARS",
  #             "reference_id": ASSOCIATED_REFERENCE_ID,
  #             "site_id": "MLA",
  #             "client_id": 0,
  #             "financial_entity": "master",
  #             "status": "available",
  #             "label": [],
  #             "date_created": "2013-09-23T12:01:30.000-04:00",
  #             "date_released": "2013-09-25T12:01:30.000-04:00",
  #             "balanced_amount": 0,
  #             "original_move_id": null
  #         },
  #         {
  #             ...
  #         }
  #     ]
  # }
  #

  module Movements

    def self.search(access_token, filters = {})
      payload = filters.merge(access_token: access_token)
      headers = { accept: 'application/json' }
      MercadoPago::Request.make_request(:get, "/mercadopago_account/movements/search", payload, headers)
    end

  end

end