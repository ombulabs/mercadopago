module MercadoPago
 
  class AccessError < Exception
  end

  # You can create a Client object to interact with a MercadoPago
  # account through the API.
  #
  # You will need client_id and client_secret. Client will save
  # the token as part of its inner state. It will use it to call
  # API methods.
  #
  # Usage:
  #
  #     c = Client.new(client_id, client_secret)
  #     c.create_preference(data)
  #
  class Client
    attr_reader :token

    # Creates an instance and stores the 
    # access_token to make calls to the 
    # MercadoPago API.
    def initialize(client_id, client_secret)
      response = MercadoPago::Authentication.access_token(client_id, client_secret)
      
      unless @token = response["access_token"]   
        raise AccessError, response["message"]
      end
    end

    # Creates a payment preference according to the
    # data parameter.
    def create_preference(data)
      MercadoPago::Checkout.create_preference(@token, data)
    end

    # Returns the payment preference according to the
    # id parameter.
    def get_preference(preference_id)
      MercadoPago::Checkout.get_preference(@token, preference_id) 
    end

  end

end

