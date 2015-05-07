module MercadoPago
  module CustomCheckout
    module Customers
      def self.create(access_token, payload)
        headers = { content_type: 'application/json', accept: 'application/json' }
        MercadoPago::Request.wrap_post("/v1/customers?access_token=#{access_token}", payload, headers)
      end

      def self.get(access_token, customer_id)
        headers = { accept: 'application/json' }
        MercadoPago::Request.wrap_get("/v1/customers/#{customer_id}?access_token=#{access_token}", headers)
      end

      def self.search(access_token, payload)
        headers = { accept: 'application/json' }
        MercadoPago::Request.wrap_get("/v1/customers/search?access_token=#{access_token}", payload, headers)
      end

      def self.update(access_token, customer_id, payload)
        headers = { content_type: 'application/json', accept: 'application/json' }
        MercadoPago::Request.wrap_put("/v1/customers/#{customer_id}?access_token=#{access_token}", payload, headers)
      end
    end
  end
end