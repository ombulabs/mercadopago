module MercadoPago
  module CustomCheckout
    module CardTokens
      def self.get(access_token, card_token_id)
        MercadoPago::Request.wrap_get("/v1/card_tokens/#{card_token_id}?access_token=#{access_token}")
      end

      def self.update(access_token, card_token_id, payload)
        payload = JSON.generate(payload)
        MercadoPago::Request.wrap_put("/v1/card_tokens/#{card_token_id}?access_token=#{access_token}", payload)
      end
    end
  end
end
