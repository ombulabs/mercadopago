require 'faraday'
require 'json'

module MercadoPago

  module Request

    class ClientError < Exception
    end

    MIME_JSON = 'application/json'
    MERCADOPAGO_RUBY_SDK_VERSION = '0.3.4'

    #
    # This URL is the base for all API calls.
    #
    MERCADOPAGO_URL = 'https://api.mercadopago.com'

    def self.default_headers
      {
        'User-Agent' => "MercadoPago Ruby SDK v" + MERCADOPAGO_RUBY_SDK_VERSION,
        content_type: MIME_JSON,
        accept: MIME_JSON
      }
    end
    #
    # Makes a POST request to the MercadoPago API.
    #
    # - path: the path of the API to be called.
    # - payload: the data to be trasmitted to the API.
    # - headers: the headers to be transmitted over the HTTP request.
    #
    def self.wrap_post(path, payload, headers = {})
      raise ClientError('No data given') if payload.nil? or payload.empty?
      make_request(:post, path, payload, headers)
    end

    #
    # Makes a GET request to the MercadoPago API.
    #
    # - path: the path of the API to be called, including any query string parameters.
    # - headers: the headers to be transmitted over the HTTP request.
    #
    def self.wrap_get(path, headers = {})
      make_request(:get, path, nil, headers)
    end

    #
    # Makes a PUT request to the MercadoPago API.
    #
    # - path: the path of the API to be called, including any query string parameters.
    # - headers: the headers to be transmitted over the HTTP request.
    #
    def self.wrap_put(path, payload, headers = {})
      make_request(:put, path, payload, headers)
    end

    #
    # Makes a HTTP request to the MercadoPago API.
    #
    # - type: the HTTP request type (:get, :post, :put, :delete).
    # - path: the path of the API to be called.
    # - payload: the data to be trasmitted to the API.
    # - headers: the headers to be transmitted over the HTTP request.
    #
    def self.make_request(type, path, payload = nil, headers = {})
      headers = default_headers.merge(headers)
      ssl_option = { verify: true }
      connection = Faraday.new(MERCADOPAGO_URL, ssl: ssl_option)

      response = connection.send(type) do |req|
        req.url path
        req.headers = headers
        req.body = payload
      end

      JSON.load(response.body)
    rescue Exception => e
      if e.respond_to?(:response)
        JSON.load(e.response)
      else
        raise e
      end
    end

  end

end
