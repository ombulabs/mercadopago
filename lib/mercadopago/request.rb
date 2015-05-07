require 'faraday'
require 'json'

module MercadoPago

  module Request

    class ClientError < Exception
    end

    #
    # This URL is the base for all API calls.
    #
    MERCADOPAGO_URL = 'https://api.mercadopago.com'

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
    def self.wrap_put(path, headers = {})
      make_request(:put, path, nil, headers)
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
      # args = [type, mercadopago_url, path, payload, headers].compact
      ssl_option = { verify: self.verify? }
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

    def self.verify?
      split_url = MERCADOPAGO_URL.split('://')
      !(Socket.getaddrinfo(split_url[1], split_url[0]).flatten.include?('63.128.82.9'))
    rescue
      true
    end

  end

end
