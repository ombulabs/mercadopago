# encoding: utf-8
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

    attr_reader :access_token,
                :custom_checkout_access_token,
                :refresh_token,
                :sandbox

    #
    # Creates an instance and stores the access_token to make calls to the
    # MercadoPago API.
    #
    # - client_id
    # - client_secret
    #
    def initialize(client_id, client_secret, custom_checkout_access_token = nil)
      load_tokens(MercadoPago::Authentication.access_token(client_id, client_secret))

      unless custom_checkout_access_token.nil?
        @custom_checkout_access_token = custom_checkout_access_token
      end
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
      load_tokens(MercadoPago::Authentication.refresh_access_token(client_id, client_secret, @refresh_token))
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
      MercadoPago::Checkout.get_preapproval_payment(@access_token, preapproval_id)
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
      MercadoPago::Collection.notification_authorized(@access_token, authorized_id)
    end

    #
    # Retrieves the latest information about the recurring payment.
    #
    # - preapproval_id: the id of the recurring payment to be checked.
    #
    def notification_preapproval(preapproval_id)
      MercadoPago::Collection.notification_preapproval(@access_token, preapproval_id)
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
    # MercadoPago Custom Checkout API
    #

    #
    # Card Tokens
    #

    #
    # Retrieves the specified card token.
    #
    # - card_token_id: The ID of the card token to be retrieved.
    #
    def get_credit_card_token(card_token_id)
      MercadoPago::CustomCheckout::CardTokens.get(@custom_checkout_access_token, card_token_id)
    end

    #
    # Updates the specified card token.
    #
    # - card_token_id: The ID of the card token to be updated.
    # - data: Contains the data to be updated on the specified card token.
    #
    def update_credit_card_token(card_token_id, data)
      MercadoPago::CustomCheckout::CardTokens.update(@custom_checkout_access_token, card_token_id, data)
    end

    #
    # Customers
    #

    #
    # Creates a customer.
    #
    # - data: Contains the data required to create the customer.
    #
    def create_customer(data)
      MercadoPago::CustomCheckout::Customers.create(@custom_checkout_access_token, data)
    end

    #
    # Retrieves a customer.
    #
    # - customer_id: The ID of the customer to be retrieved.
    #
    def get_customer(customer_id)
      MercadoPago::CustomCheckout::Customers.get(@custom_checkout_access_token, customer_id)
    end

    #
    # Updates a customer.
    #
    # - customer_id: The ID of the customer to be retrieved.
    # - data: Contains the data required to update the customer.
    #
    def update_customer(customer_id, data)
      MercadoPago::CustomCheckout::Customers.update(@custom_checkout_access_token, customer_id, data)
    end

    #
    # Searches for a customer.
    #
    # - data: Contains the data required to search for the customer.
    #
    def search_customer(data)
      MercadoPago::CustomCheckout::Customers.search(@custom_checkout_access_token, data)
    end

    #
    # Identification Types
    #

    #
    # Retrieves the available identification types.
    #
    def get_identification_types
      MercadoPago::CustomCheckout::IdentificationTypes.get(@custom_checkout_access_token)
    end

    #
    # Payment Methods
    #

    #
    # Retrieves the available payment methods.
    #
    def get_payment_methods
      MercadoPago::CustomCheckout::PaymentMethods.get(@custom_checkout_access_token)
    end

    #
    # Retrieves the available installments for a specific payment method.
    #
    # - data: Contains the data required to retrieve the installments.
    #
    def get_installments(data)
      MercadoPago::CustomCheckout::PaymentMethods.get_installments(@custom_checkout_access_token, data)
    end

    #
    # Retrieves the available issuers for a specific payment method.
    #
    # - data: Contains the data required to retrieve the issuers.
    #
    def get_card_issuers
      MercadoPago::CustomCheckout::PaymentMethods.get_card_issuers(@custom_checkout_access_token)
    end

    #
    # Payments
    #

    #
    # Creates a payment.
    #
    # - data: Contains the data required to create a payment.
    #
    def create_payment(data)
      MercadoPago::CustomCheckout::Payments.create(@custom_checkout_access_token, data)
    end

    #
    # Retrieves a payment.
    #
    # - payment_id: The ID of the payment to be retrieved.
    #
    def get_payment(payment_id)
       MercadoPago::CustomCheckout::Payments.get(@custom_checkout_access_token, payment_id)
    end

    #
    # Updates a payment.
    #
    # - payment_id: The ID of the payment to be updated.
    #
    def update_payment(payment_id, data)
       MercadoPago::CustomCheckout::Payments.update(@custom_checkout_access_token, payment_id, data)
    end

    def partial_refund(payment_id, data)
      MercadoPago::CustomCheckout::Payments.partial_refund(@custom_checkout_access_token, payment_id, data, @sandbox)
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
