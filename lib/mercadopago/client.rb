# encoding: utf-8
require 'json'
require 'uri'

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
  #
  #  mp_client.create_preference(data)
  #  mp_client.get_preference(preference_id)
  #  mp_client.notification(payment_id)
  #  mp_client.search(data)
  #  mp_client.sandbox_mode(true/false)
  #
  class Client

    attr_reader :access_token, :refresh_token, :sandbox

    #
    # Creates an instance and stores the access_token to make calls to the
    # MercadoPago API.
    #
    # - client_id
    # - client_secret
    #
    def initialize(client_id, client_secret)
      load_tokens MercadoPago::Authentication.access_token(client_id,
                                                           client_secret)
    end

    #
    # Enables or disables sandbox mode.
    #
    # - enable
    #
    def sandbox_mode(enable = nil)
      unless enable.nil?
        @sandbox = enable
      end
      @sandbox
    end

    #
    # Refreshes an access token.
    #
    # - client_id
    # - client_secret
    #
    def refresh_access_token(client_id, client_secret)
      load_tokens(MercadoPago::Authentication
        .refresh_access_token(client_id, client_secret, @refresh_token))
    end

    #
    # Creates a payment preference.
    #
    # - data: contains the data according to the payment preference that will be created.
    #
    def create_preference(data)
      MercadoPago::Checkout.create_preference(@access_token, data)
    end

    #
    # Returns the payment preference.
    #
    # - preference_id: the id of the payment preference that will be retrieved.
    #
    def get_preference(preference_id)
      MercadoPago::Checkout.get_preference(@access_token, preference_id)
    end

    #
    # Creates a recurring payment.
    #
    # - data: contains the data according to the recurring payment that will be created.
    #
    def create_preapproval_payment(data)
      MercadoPago::Checkout.create_preapproval_payment(@access_token, data)
    end

    #
    # Returns the recurring payment.
    #
    # - preapproval_id: the id of the preapproval payment preference that will be retrieved.
    #
    def get_preapproval_payment(preapproval_id)
      MercadoPago::Checkout.get_preapproval_payment(@access_token,
                                                    preapproval_id)
    end

    #
    # Cancels a recurring payment.
    #
    # - data: contains the data according to the recurring payment that will be created.
    #
    def cancel_preapproval_payment(preapproval_id)
      MercadoPago::Checkout.cancel_preapproval_payment(@access_token, preapproval_id)
    end

    #
    # Retrieves the latest information about a payment or a merchant order.
    #
    # - entity_id: the id of the entity (paymento or merchant order) to be checked.
    #
    def notification(entity_id, topic = 'payment')
      case topic.to_s
      when 'merchant_order'
        MercadoPago::MerchantOrder.notification(@access_token, entity_id)
      else # 'payment'
        MercadoPago::Collection.notification(@access_token, entity_id, @sandbox)
      end
    end

    #
    # Retrieves the latest information about the recurring payment after authorized.
    #
    # - authorized_id: the id of the recurring payment authorized to be checked.
    #
    def notification_authorized(authorized_id)
      MercadoPago::Collection.notification_authorized(@access_token,
                                                      authorized_id)
    end

    #
    # Retrieves the latest information about the recurring payment.
    #
    # - preapproval_id: the id of the recurring payment to be checked.
    #
    def notification_preapproval(preapproval_id)
      MercadoPago::Collection.notification_preapproval(@access_token,
                                                       preapproval_id)
    end

    #
    # Searches for collections that matches some of the search hash criteria.
    #
    # - search_hash: the search hash to find collections.
    #
    def search(search_hash)
      MercadoPago::Collection.search(@access_token, search_hash, @sandbox)
    end

    #
    # Performs a generic GET to the given URL
    #
    # - url: the URL to request
    #
    def get(url, data = {}, headers = nil)
      data[:access_token] = @access_token
      query = URI.encode_www_form data

      MercadoPago::Request.wrap_get("#{url}?{query}", headers)
    end

    #
    # Performs a generic POST to the given URL
    #
    # - url: the URL to request
    # - data: the data to send along the request
    #
    def post(url, data, headers = nil)
      payload = JSON.generate(data)

      MercadoPago::Request.wrap_post("#{url}?access_token=#{@access_token}", payload, headers)
    end

    #
    # Private methods.
    #
    private

    #
    # Loads the tokens from the authentication hash.
    #
    # - auth: the authentication hash returned by MercadoPago.
    #
    def load_tokens(auth)
      mandatory_keys = %w{ access_token refresh_token }

      if (auth.keys & mandatory_keys) == mandatory_keys
        @access_token   = auth['access_token']
        @refresh_token  = auth['refresh_token']
      else
        raise AccessError, auth['message']
      end
    end
  end
end
