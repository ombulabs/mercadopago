module MercadoPago
  module CustomCheckout
    module Payments

      def self.create(access_token, payload)
        payload = JSON.generate(payload)
        MercadoPago::Request.wrap_post("/v1/payments?access_token=#{access_token}", payload)
      end

      def self.get(access_token, payment_id)
        MercadoPago::Request.wrap_get("/v1/payments/#{payment_id}?access_token=#{access_token}")
      end

      def self.update(access_token, payment_id, payload)
        payload = JSON.generate(payload)
        MercadoPago::Request.wrap_put("/v1/payments/#{payment_id}?access_token=#{access_token}", payload)
      end

      def self.partial_refund(access_token, payment_id, payload, sandbox = false)
        payload = JSON.generate(payload)
        uri_prefix = sandbox ? '/sandbox' : ''
        MercadoPago::Request.wrap_post("#{uri_prefix}/collections/#{payment_id}/refunds?access_token=#{access_token}", payload)
      end
    end
  end
end
