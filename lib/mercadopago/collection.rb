module Mercadopago
  
  module Collection
    
    #
    # Receives an access_token and a payment id and retrieves information of the payment.
    # This is useful, for example, to check the status of a payment.
    #
    # - access_token: an access_token of the MercadoPago account associated with the payment to be checked.
    # - payment_id: the id of the payment to be checked.
    #
    def self.notification(access_token, payment_id)
      
      Mercadopago::Request.wrap_get("/collections/notifications/#{payment_id}?access_token=#{access_token}", { :accept => 'application/json' })
      
    end
    
  end
  
end