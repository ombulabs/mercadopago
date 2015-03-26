# encoding: utf-8

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/byebug' if ENV['DEBUG']
require 'httplog' if ENV['LOG']
require 'mercadopago'

# Minitest Reporter config
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]


class TestMercadoPago < Minitest::Test


  #
  # Valid credentials to be used in the tests.
  #
  CREDENTIALS = { client_id: '3962917649351233', client_secret: 'rp7Ec38haoig7zWQXekXMiqA068eS376' }

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

  # With a valid client id and secret (test account)
  def test_that_authentication_returns_access_token
    response = MercadoPago::Authentication.access_token(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])
    assert response['access_token']
  end

  # Using fake client id and client secret
  def test_that_authentication_fails_with_wrong_parameters
    response = MercadoPago::Authentication.access_token('fake_client_id', 'fake_client_secret')

    assert_nil response['access_token']
    assert_equal "invalid_client", response['error']
  end

  def test_that_refresh_token_works
    auth = MercadoPago::Authentication.access_token(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])
    refresh = MercadoPago::Authentication.refresh_access_token(CREDENTIALS[:client_id], CREDENTIALS[:client_secret], auth['refresh_token'])

    assert refresh['access_token']
    assert refresh['refresh_token']
    assert refresh['access_token'] != auth['access_token']
    assert refresh['refresh_token'] != auth['refresh_token']
  end

  # Using fake token
  def test_that_request_fails_with_wrong_token
    response = MercadoPago::Checkout.create_preference('fake_token', {})

    assert_equal 'Malformed access_token: fake_token', response['message']
    assert_equal 'bad_request', response['error']
  end

  def test_that_client_initializes_okay_with_valid_details
    mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])
    assert mp_client.access_token
  end

  def test_that_client_fails_with_wrong_details
    assert_raises(MercadoPago::AccessError) do
      mp_client = MercadoPago::Client.new('fake_client_id', 'fake_client_secret')
    end
  end

  def test_that_client_can_create_payment_preference
    mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])
    response = mp_client.create_preference(PAYMENT_REQUEST)
    assert response['init_point']
  end

  def test_that_client_can_get_preference
    mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])

    response = mp_client.create_preference(PAYMENT_REQUEST)
    assert pref_id = response['id']

    response = mp_client.get_preference(pref_id)
    assert_equal "https://www.mercadopago.com/mlb/checkout/pay?pref_id=#{pref_id}", response['init_point']
  end

  def test_that_client_can_get_payment_notification
    payment_id = 849707350
    mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])

    response = mp_client.notification(payment_id)
    assert_equal payment_id, response['collection']['id']
  end

  def test_that_client_can_get_merchant_order_notification
    payment_id = 61166827
    mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])

    response = mp_client.notification(payment_id, 'merchant_order')
    assert_equal payment_id, response['id']
  end

  def test_that_client_can_search
    mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])
    response = mp_client.search(status: :refunded)

    assert response.has_key?('results')

    external_reference = '55723'
    response = mp_client.search(external_reference: external_reference)
    results = response['results']

    assert_equal 1, results.length
    assert_equal external_reference, results[0]['collection']['external_reference']
  end



end
