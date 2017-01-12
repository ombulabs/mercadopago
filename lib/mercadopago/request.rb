require 'faraday'
require 'json'

module MercadoPago

  module Request

    class ClientError < Exception
    end

    CONTENT_HEADERS = {
      content_type: 'application/json',
      accept: 'application/json'
    }.freeze

    #
    # This URL is the base for all API calls.
    #
    MERCADOPAGO_URL = 'https://api.mercadopago.com'.freeze

    #
    # Makes a POST request to a MercadoPago API.
    #
    # - path: the path of the API to be called.
    # - payload: the data to be trasmitted to the API.
    # - headers: the headers to be transmitted over the HTTP request.
    #
    def self.wrap_post(path, payload, headers = CONTENT_HEADERS)
      raise ClientError('No data given') if payload.nil? or payload.empty?
      make_request(:post, path, payload, headers)
    end

    #
    # Makes a GET request to a MercadoPago API.
    #
    # - path: the path of the API to be called, including any query string parameters.
    # - headers: the headers to be transmitted over the HTTP request.
    #
    def self.wrap_get(path, headers = {})
      make_request(:get, path, nil, headers)
    end

    #
    # Makes a HTTP request to a MercadoPago API.
    #
    # - type: the HTTP request type (:get, :post, :put, :delete).
    # - path: the path of the API to be called.
    # - payload: the data to be trasmitted to the API.
    # - headers: the headers to be transmitted over the HTTP request.
    #
    def self.make_request(type, path, payload = nil, headers = {})
      args = [type, MERCADOPAGO_URL, path, payload, headers].compact

      connection = Faraday.new(MERCADOPAGO_URL)

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
