module MercadoPago
  module CustomCheckout
    module Customers
      def self.create(access_token, payload)
        payload = JSON.generate(payload)
        MercadoPago::Request.wrap_post("/v1/customers?access_token=#{access_token}", payload)
      end

      def self.get(access_token, customer_id)
        MercadoPago::Request.wrap_get("/v1/customers/#{customer_id}?access_token=#{access_token}")
      end

      def self.search(access_token, payload)
        payload = JSON.generate(payload)
        MercadoPago::Request.make_request(:get, "/v1/customers/search?access_token=#{access_token}", payload)
      end

      def self.update(access_token, customer_id, payload)
        payload = JSON.generate(payload)
        MercadoPago::Request.wrap_put("/v1/customers/#{customer_id}?access_token=#{access_token}", payload)
      end
    end
  end
end
