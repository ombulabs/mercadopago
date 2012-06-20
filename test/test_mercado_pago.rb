# encoding: utf-8

require 'minitest/autorun'
require 'mercadopago'

class TestMercadoPago < MiniTest::Unit::TestCase
  PAYMENT_REQUEST = {
      "external_reference" => "OPERATION-ID-1234",
      "items" => [
        {
          "id" => "Código 123",
          "title" => "River Plate T-Shirt",
          "description" => "Red XL T-Shirt",
          "quantity" => 1,
          "unit_price" => 10.50,
          "currency_id" => "ARS",
          "picture_url" => "http://s3.amazonaws.com/ombu_store_production/images/products/1375/product/l-idiot-savant-rare-device-tee.jpeg"
        }
      ],
      "payer" => {
        "name"=> "João",
        "surname"=> "Silva",
        "email"=> "comprador@email.com.br"
      },
      "back_urls"=> {
        "pending"=> "https://www.site.com.br/pending",
        "success"=> "http://www.site.com.br/success",
        "failure"=> "http://www.site.com.br/failure"
      }
    }


  # With a valid client id and secret (test account)
  def test_that_authentication_returns_access_token
    response = MercadoPago::Authentication.access_token('8897', 'PC2MoR6baSu75xZnkhLRHoyelnpLkNbh')
    assert response["access_token"]
  end

  # Using fake client id and client secret
  def test_that_authentication_fails_with_wrong_parameters
    response = MercadoPago::Authentication.access_token('fake_client_id', 'fake_client_secret')
    assert_nil response["access_token"]
    assert_equal response["error"], "invalid_client"
  end

  # Using fake token
  def test_that_request_fails_with_wrong_token
    response = MercadoPago::Checkout.create_preference('fake_token', {})
    assert_equal response["message"], "Malformed access_token: fake_token"
    assert_equal response["error"], "bad_request"
  end

  def test_that_client_initializes_okay_with_valid_details
    client = MercadoPago::Client.new('8897', 'PC2MoR6baSu75xZnkhLRHoyelnpLkNbh')
    assert client.token
  end

  def test_that_client_fails_with_wrong_details
    assert_raises(MercadoPago::AccessError) do
      client = MercadoPago::Client.new('fake_client_id', 'fake_client_secret')
    end
  end

  def test_that_client_can_create_payment_preference
    client = MercadoPago::Client.new('8897', 'PC2MoR6baSu75xZnkhLRHoyelnpLkNbh')
    response = client.create_preference(PAYMENT_REQUEST)
    assert response["init_point"]
  end

  def test_that_client_can_get_preference
    client = MercadoPago::Client.new('8897', 'PC2MoR6baSu75xZnkhLRHoyelnpLkNbh')
    response = client.create_preference(PAYMENT_REQUEST)
    assert pref_id = response["id"]
    response = client.get_preference(pref_id)
    assert_equal response["init_point"], "https://www.mercadopago.com/mla/checkout/pay?pref_id=#{pref_id}"
  end

end


