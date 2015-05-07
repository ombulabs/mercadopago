module MercadoPago
  module CustomCheckout
    module IdentificationTypes
      def self.get(access_token)
        headers = { accept: 'application/json' }
        MercadoPago::Request.wrap_get("/v1/identification_types?access_token=#{access_token}", headers)
      end
    end
  end
end