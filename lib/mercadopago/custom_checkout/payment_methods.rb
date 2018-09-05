module MercadoPago
  module CustomCheckout
    module PaymentMethods
      def self.get(access_token)
        MercadoPago::Request.wrap_get("/v1/payment_methods?access_token=#{access_token}")
      end

      def self.get_installments(access_token, payload)
        payload = JSON.generate(payload)
        MercadoPago::Request.make_request(:get, "/v1/payment_methods/installments?access_token=#{access_token}", payload)
      end

      def self.get_card_issuers(access_token, payload)
        MercadoPago::Request.wrap_get("/v1/payment_methods/card_issuers?access_token=#{access_token}&payment_method_id=#{payload}")
      end
    end
  end
end
