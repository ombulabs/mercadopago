module MercadoPago
  module CustomCheckout
    module CardTokens
      def self.get(access_token, card_token_id)
        headers = { accept: 'application/json' }
        MercadoPago::Request.wrap_get("/v1/card_tokens/#{card_token_id}?access_token=#{access_token}", headers)
      end

      def self.update(access_token, card_token_id, payload)
        headers = { content_type: 'application/json', accept: 'application/json' }
        MercadoPago::Request.wrap_put("/v1/card_tokens/#{card_token_id}?access_token=#{access_token}", payload, headers)
      end
    end
  end
end