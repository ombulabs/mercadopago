# encoding: utf-8

require File.expand_path('../../lib/mercadopago', __FILE__)

require 'test/unit'
require 'vcr'

#
# Valid credentials to be used in the tests.
#
CREDENTIALS = {
  client_id: '3962917649351233',
  client_secret: 'rp7Ec38haoig7zWQXekXMiqA068eS376' }

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.filter_sensitive_data('<CLIENT-ID>') { CREDENTIALS[:client_id] }
  config.filter_sensitive_data('<CLIENT-SECRET>') { CREDENTIALS[:client_secret] }
end

class TestMercadoPago < Test::Unit::TestCase
  #
  # Example payment request.
  #
  PAYMENT_REQUEST = {
    external_reference: 'OPERATION-ID-1234',
    items: [
      {
        id:          'Código 123',
        title:       'Example T-Shirt',
        description: 'Red XL T-Shirt',
        quantity:    1,
        unit_price:  0.50,
        currency_id: 'BRL',
        picture_url: 'http://s3.amazonaws.com/ombu_store_production/images/products/1375/product/l-idiot-savant-rare-device-tee.jpeg'
      }
    ],
    payer: {
      name:    'John',
      surname: 'Mikel',
      email:   'buyer@email.com'
    },
    back_urls: {
      pending: 'https://www.site.com/pending',
      success: 'http://www.site.com/success',
      failure: 'http://www.site.com/failure'
    }
  }

  #
  # Example preapproval request
  #
  PREAPPROVAL_REQUEST = {
    payer_email: "buyer@email.com",
    back_url: "http://www.example.com/payment_complete",
    reason: "reason text",
    external_reference: "order_id 1234",
    auto_recurring: {
      frequency: 1,
      frequency_type: :months,
      transaction_amount:  12.99,
      currency_id:  "ARS"
    }
  }

  # With a valid client id and secret (test account)
  def test_that_authentication_returns_access_token
    VCR.use_cassette("login", match_requests_on: [:path]) do
      @response = MercadoPago::Authentication
                    .access_token(CREDENTIALS[:client_id],
                                  CREDENTIALS[:client_secret])
    end

    assert @response['access_token']
  end

  # Using fake client id and client secret
  def test_that_authentication_fails_with_wrong_parameters
    VCR.use_cassette("wrong login") do
      @response = MercadoPago::Authentication.access_token('fake_client_id',
                                                           'fake_client_secret')
    end

    assert_nil @response['access_token']
    assert_equal "bad_request", @response['error']
  end

  # TODO: make test work again
  # def test_that_refresh_token_works
  #   VCR.use_cassette("access_token") do
  #     @auth = MercadoPago::Authentication
  #               .access_token(CREDENTIALS[:client_id],
  #                             CREDENTIALS[:client_secret])
  #   end
  #   VCR.use_cassette("refresh_token") do
  #     @refresh = MercadoPago::Authentication.refresh_access_token(
  #       CREDENTIALS[:client_id],
  #       CREDENTIALS[:client_secret],
  #       @auth['refresh_token']
  #     )
  #   end
  #
  #   assert @refresh['access_token']
  #   assert @refresh['refresh_token']
  #   assert @refresh['access_token'] != @auth['access_token']
  #   assert @refresh['refresh_token'] != @auth['refresh_token']
  # end

  def test_that_request_fails_with_wrong_token
    VCR.use_cassette("wrong token") do
      @response = MercadoPago::Checkout.create_preference('fake_token', {})
    end
    assert_equal 'Malformed access_token: null', @response['message']
    assert_equal 'bad_request', @response['error']
  end

  def test_that_client_initializes_okay_with_valid_details
    VCR.use_cassette("login", match_requests_on: [:path]) do
      @mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id],
                                           CREDENTIALS[:client_secret])
    end

    assert @mp_client.access_token
  end

  def test_that_client_fails_with_wrong_details
    assert_raises(MercadoPago::AccessError) do
      VCR.use_cassette("wrong login") do
        @mp_client = MercadoPago::Client.new('fake_client_id',
                                             'fake_client_secret')
      end
    end
  end

  def test_that_client_can_create_payment_preference
    VCR.use_cassette("login", match_requests_on: [:path]) do
      @mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id],
                                           CREDENTIALS[:client_secret])
    end

    VCR.use_cassette("create preference", match_requests_on: [:method, :path]) do
      @response = @mp_client.create_preference(PAYMENT_REQUEST)
    end
    assert @response['init_point']
  end

  def test_that_client_can_get_preference
    VCR.use_cassette("login", match_requests_on: [:path]) do
      @mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id],
                                           CREDENTIALS[:client_secret])
    end

    VCR.use_cassette("create preference", match_requests_on: [:method, :path]) do
      @response = @mp_client.create_preference(PAYMENT_REQUEST)
    end
    assert @pref_id = @response['id']

    VCR.use_cassette("get preference", match_requests_on: [:method, :path]) do
      @response = @mp_client.get_preference(@pref_id)
    end
    assert_match /https\:\/\/www\.mercadopago\.com\/ml(a|b)\/checkout\/start\?pref\_id\=#{@pref_id}/, @response['init_point']
  end

  # TODO: make test work again
  # def test_that_client_can_get_payment_notification
  #   VCR.use_cassette("login", match_requests_on: [:path]) do
  #     @mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])
  #   end
  #
  #   @payment_id = 849707350
  #   VCR.use_cassette("notification") do
  #     @response = @mp_client.notification(@payment_id)
  #   end
  #
  #   assert_equal @payment_id, @response['collection']['id']
  # end

  # TODO: make test work again
  # def test_that_client_can_get_merchant_order_notification
  #   payment_id = 61166827
  #   VCR.use_cassette("login", match_requests_on: [:path]) do
  #     @mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])
  #   end
  #
  #   VCR.use_cassette("merchant notification") do
  #     @response = @mp_client.notification(payment_id, 'merchant_order')
  #   end
  #   assert_equal payment_id, @response['id']
  # end

  # TODO: make test work again
  # def test_that_client_can_search
  #   VCR.use_cassette("login", match_requests_on: [:path]) do
  #     @mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])
  #   end
  #
  #   VCR.use_cassette("search status") do
  #     @response = @mp_client.search(status: :refunded)
  #   end
  #
  #   assert @response.has_key?('results')
  #
  #   external_reference = '55723'
  #
  #   VCR.use_cassette("search external reference") do
  #     @response = @mp_client.search(external_reference: external_reference)
  #   end
  #   results = @response['results']
  #
  #   assert_equal 1, results.length
  #   assert_equal external_reference, results[0]['collection']['external_reference']
  # end
end
