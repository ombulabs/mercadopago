module MercadoPago
  module CustomCheckout
    module IdentificationTypes
      def self.get(access_token)
        MercadoPago::Request.wrap_get("/v1/identification_types?access_token=#{access_token}")
      end
    end
  end
end
