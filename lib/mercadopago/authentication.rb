module MercadoPago

  module Authentication

    CONTENT_HEADERS = {
      content_type: 'application/x-www-form-urlencoded',
      accept: 'application/json'
    }.freeze
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
      payload = {
        grant_type: 'client_credentials',
        client_id: client_id,
        client_secret: client_secret }

      MercadoPago::Request.wrap_post('/oauth/token', payload, CONTENT_HEADERS)
    end

    #
    # Receives the client credentials and a valid refresh token and requests a new access token.
    #
    # - client_id
    # - client_secret
    # - refresh_token
    #
    def self.refresh_access_token(client_id, client_secret, refresh_token)
      payload = {
        grant_type: 'refresh_token',
        client_id: client_id,
        client_secret: client_secret,
        refresh_token: refresh_token }

      MercadoPago::Request.wrap_post('/oauth/token', payload, CONTENT_HEADERS)
    end
  end
end
