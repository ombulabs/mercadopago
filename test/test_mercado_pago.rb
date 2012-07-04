# encoding: utf-8

require 'minitest/autorun'
require 'mercadopago'

class TestMercadoPago < MiniTest::Unit::TestCase
  
  #
  # Valid credentials to be used in the tests.
  #
  CREDENTIALS = {
    :client_id      => '8897',
    :client_secret  => 'PC2MoR6baSu75xZnkhLRHoyelnpLkNbh'
  }
  
  #
  # Example payment request.
  #
  PAYMENT_REQUEST = {
    "external_reference" => "OPERATION-ID-1234",
    "items" => [
      {
        "id"          => "Código 123",
        "title"       => "Example T-Shirt",
        "description" => "Red XL T-Shirt",
        "quantity"    => 1,
        "unit_price"  => 10.50,
        "currency_id" => "ARS",
        "picture_url" => "http://s3.amazonaws.com/ombu_store_production/images/products/1375/product/l-idiot-savant-rare-device-tee.jpeg"
      }
    ],
    "payer" => {
      "name"    => "John",
      "surname" => "Mikel",
      "email"   => "buyer@email.com"
    },
    "back_urls" => {
      "pending" => "https://www.site.com/pending",
      "success" => "http://www.site.com/success",
      "failure" => "http://www.site.com/failure"
    }
  }
  
  # With a valid client id and secret (test account)
  def test_that_authentication_returns_access_token
    response = MercadoPago::Authentication.access_token(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])
    assert response["access_token"]
  end
  
  # Using fake client id and client secret
  def test_that_authentication_fails_with_wrong_parameters
    response = MercadoPago::Authentication.access_token('fake_client_id', 'fake_client_secret')
    assert_nil response["access_token"]
    assert_equal "invalid_client", response["error"]
  end
  
  # Using fake token
  def test_that_request_fails_with_wrong_token
    response = MercadoPago::Checkout.create_preference('fake_token', {})
    assert_equal "Malformed access_token: fake_token", response["message"]
    assert_equal "bad_request", response["error"]
  end
  
  def test_that_client_initializes_okay_with_valid_details
    mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])
    assert mp_client.token
  end
  
  def test_that_client_fails_with_wrong_details
    assert_raises(MercadoPago::AccessError) do
      mp_client = MercadoPago::Client.new('fake_client_id', 'fake_client_secret')
    end
  end
  
  def test_that_client_can_create_payment_preference
    mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])
    response = mp_client.create_preference(PAYMENT_REQUEST)
    assert response["init_point"]
  end
  
  def test_that_client_can_get_preference
    mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])
    
    response = mp_client.create_preference(PAYMENT_REQUEST)
    assert pref_id = response["id"]
    
    response = mp_client.get_preference(pref_id)
    assert_equal "https://www.mercadopago.com/mla/checkout/pay?pref_id=#{pref_id}", response["init_point"]
  end

  def test_that_client_can_get_notification
    payment_id = 419470268

    # The payment_id needs to belong to the account whose credentials were used to create the client.
    # When we have a payment_id that matches this requirement, uncomment the line bellow and remove the next one.
    mp_client = MercadoPago::Client.new(CREDENTIALS[:client_id], CREDENTIALS[:client_secret])

    response = mp_client.notification(payment_id)
    assert_equal payment_id, response['collection']['id']
  end

end
