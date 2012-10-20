module MercadoPago
 
  class AccessError < Exception
  end
  
  #
  # You can create a Client object to interact with a MercadoPago
  # account through the API.
  #
  # You will need client_id and client_secret. Client will save
  # the token as part of its inner state. It will use it to call
  # API methods.
  #
  # Usage example:
  #
  #  mp_client = MercadoPago::Client.new(client_id, client_secret)
  #  mp_client.create_preference(data)
  #
  class Client
    attr_reader :token
    
    #
    # Creates an instance and stores the 
    # access_token to make calls to the 
    # MercadoPago API.
    #
    def initialize(client_id, client_secret)
      response = MercadoPago::Authentication.access_token(client_id, client_secret)
      
      unless @token = response["access_token"]   
        raise AccessError, response["message"]
      end
    end
    
    #
    # Creates a payment preference.
    #
    # - data: contains the data according to the payment preference will be created.
    #
    def create_preference(data)
      MercadoPago::Checkout.create_preference(@token, data)
    end
    
    #
    # Returns the payment preference.
    #
    # - preference_id: the id of the payment preference that will be retrieved.
    #
    def get_preference(preference_id)
      MercadoPago::Checkout.get_preference(@token, preference_id) 
    end
    
    #
    # Retrieves the latest information about a payment.
    #
    # - payment_id: the id of the payment to be checked.
    #
    def notification(payment_id)
      MercadoPago::Collection.notification(@token, payment_id)
    end
    
    #
    # Search for collections that matches some of the search hash criteria.
    #
    # - search_hash: the search hash to find collections
    #
    def search(search_hash)
      MercadoPago::Collection.search(@token, search_hash)
    end
  end
  
end