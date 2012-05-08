module Mercadopago
  
  module Authentication
    
    #
    # Receives the client credentials and makes a request to oAuth API.
    # On success, returns a hash with the access data; on failure, returns nil.
    #
    # To get your client credentials, access:
    # https://www.mercadopago.com/mlb/ferramentas/aplicacoes
    # 
    # - client_id
    # - client_secret
    #
    def self.access_token(client_id, client_secret)
      
      payload = { :grant_type => 'client_credentials', :client_id => client_id, :client_secret => client_secret }
      headers = { :content_type => 'application/x-www-form-urlencoded', :accept => 'application/json' }
      
      Mercadopago::Request.wrap_post('/oauth/token', payload, headers)
      
    end
    
    #
    # TODO
    #
    def refresh_access_token
      
      # TODO
      
    end
    
  end
  
end