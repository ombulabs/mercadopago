MercadoPago Gem
===============

Developed by [Kauplus](http://www.kauplus.com) and maintained by [Ombulabs](http://www.ombulabs.com).

This is a Ruby client for all the services offered by [MercadoPago](http://www.mercadopago.com).

You should read the MercadoPago API documentation before you use this gem. This gem works with hashes and only deals with requests/responses. That's why you will need an understanding of their services.

You can read the documentation of the MercadoPago API here:
* Portuguese: https://developers.mercadopago.com/integracao-checkout
* Spanish: https://developers.mercadopago.com/integracion-checkout

Installation
------------

mercadopago 2.0.0+ needs Ruby 1.9+. Version 1.0.2 runs fine with Ruby 1.8.

To install the last version of the gem:

    gem install mercadopago

If you are using bundler, add this to your Gemfile:

    gem 'mercadopago'

Access Credentials
------------------

To use this gem, you will need the client_id and client_secret for a MercadoPago account.

In any case, this gem will not store this information. In order to find out your MercadoPago credentials, you can go here:

* Brasil: https://www.mercadopago.com/mlb/ferramentas/aplicacoes
* Argentina: https://www.mercadopago.com/mla/herramientas/aplicaciones

How to use
----------

### Client creation

The first thing to do is create a client. The client will authenticate with MercadoPago and will allow you to interact with the MercadoPago API.

    # Use your credentials
    client_id = '1234'
    client_secret = 'abcdefghijklmnopqrstuvwxyz'

    mp_client = MercadoPago::Client.new(client_id, client_secret)

If any error ocurred while authenticating with MercadoPago, an AccessError will be raised. If nothing goes wrong, no errors are raised and you are ready to use the API.

### Payment Creation

Your request will need a hash to explain what the payment is for. For example:

    data = {
      external_reference: "OPERATION-ID-1234",
      items: [
        {
          id:           "Código 123",
          title:        "Example T-Shirt",
          description:  "Red XL T-Shirt",
          quantity:     1,
          unit_price:   10.50,
          currency_id:  "BRL",
          picture_url:  "http://www.site.com/image/123.png"
        }
      ],
      payer: {
        name:     "John",
        surname:  "Mikel",
        email:    "buyer@email.com"
      },
      back_urls: {
        pending: "https://www.site.com/pending",
        success: "http://www.site.com/success",
        failure: "http://www.site.com/failure"
      }
    }

    payment = mp_client.create_preference(data)

If everything worked out alright, you will get a response like this:

    {
      "payment_methods"    => {},
      "init_point"         => "https://www.mercadopago.com/mlb/checkout/pay?pref_id=abcdefgh-9999-9999-ab99-999999999999",
      "sandbox_init_point" => "https://sandbox.mercadopago.com/mlb/checkout/pay?pref_id=abcdefgh-9999-9999-ab99-999999999999",
      "collector_id"       => 123456789,
      "back_urls" => {
        "pending"=> "https://www.site.com/pending",
        "success"=> "http://www.site.com/success",
        "failure"=> "http://www.site.com/failure"
      },
      "sponsor_id" => nil,
      "expiration_date_from"  => nil,
      "additional_info"       => "",
      "marketplace_fee"       => 0,
      "date_created"          => "2012-05-07T20:07:52.293-04:00",
      "subscription_plan_id"  => nil,
      "id"                    => "abcdefgh-9999-9999-ab99-999999999999",
      "expiration_date_to"    => nil,
      "expires"               => false,
      "external_reference"    => "OPERATION-ID-1234",
      "payer" => {
        "email"   => "buyer@email.com",
        "name"    => "John",
        "surname" => "Mikel"
      },
      "items" => [
        {
          "id"          => "Código 123",
          "currency_id" => "BRL",
          "title"       => "Example T-Shirt",
          "description" => "Red XL T-Shirt",
          "picture_url" => "http://www.site.com.br/image/123.png",
          "quantity"    => 1,
          "unit_price"  => 10.50
        }
      ],
      "client_id"   => "963",
      "marketplace" => "NONE"
    }

### Payment Status Verification

To check the payment status you will need the payment ID. Only then you can call the [MercadoPago IPN](https://developers.mercadopago.com/api-ipn).

    # Use the payment ID received on the IPN.
    payment_id = '987654321'

    notification = mp_client.notification(payment_id)

You will get a response like this one:

    {
      "collection" => {
        "id"                  => 987654321,
        "site_id"             => "MLB",
        "operation_type"      => "regular_payment",
        "order_id"            => nil,
        "external_reference"  => "OPERATION-ID-1234",
        "status"              => "approved",
        "status_detail"       => "approved",
        "payment_type"        => "credit_card",
        "date_created"        => "2012-05-05T14:22:43Z",
        "last_modified"       => "2012-05-05T14:35:13Z",
        "date_approved"       => "2012-05-05T14:22:43Z",
        "money_release_date"  => "2012-05-19T14:22:43Z",
        "currency_id"         => "BRL",
        "transaction_amount"  => 10.50,
        "shipping_cost"       => 0,
        "total_paid_amount"   => 10.50,
        "finance_charge"      => 0,
        "net_received_amount" => 0,
        "marketplace"         => "NONE",
        "marketplace_fee"     => nil,
        "reason"              => "Example T-Shirt",
        "payer" => {
          "id"          => 543219876,
          "first_name"  => "John",
          "last_name"   => "Mikel",
          "nickname"    => "JOHNMIKEL",
          "phone" => {
            "area_code" => nil,
            "number"    => "551122334455",
            "extension" => nil
          },
          "email" => "buyer@email.com",
          "identification" => {
            "type"    => nil,
            "number"  => nil
          }
        },
        "collector" => {
          "id"          => 123456789,
          "first_name"  => "Bill",
          "last_name"   => "Receiver",
          "phone" => {
            "area_code" => nil,
            "number"    => "1122334455",
            "extension" => nil
          },
          "email"     => "receiver@email.com",
          "nickname"  => "BILLRECEIVER"
        }
      }
    }

### Search in the collections

To search over the collections (payments that you may be processing) you need to create a hash with the params that you want to search for an send it to the search method of the client instance.

    # Create a hash to search for
    search_hash = { external_reference: 'OPERATION-ID-1234' }

    search = mp_client.search(search_hash)

You will get a response like this one:

    {
      "results"=>[
        {
          "collection" => {
            "marketplace"   =>"NONE",
            "sponsor_id"    =>nil,
            "status"        => "approved",
            "status_detail" => "approved",
            "payer" => {
              "id"          => 543219876,
              "first_name"  => "John",
              "last_name"   => "Mikel",
              "nickname"    => "JOHNMIKEL",
              "phone" => {
                "area_code" => nil,
                "number"    => "551122334455",
                "extension" => nil
              },
              "email" => "buyer@email.com",
              "identification" => {
                "type"    => nil,
                "number"  => nil
              }
            },
            "currency_id"         => "BRL",
            "external_reference"  => "OPERATION-ID-1234",
            "transaction_amount"  => 10.50,
            "shipping_cost"       => 0,
            "total_paid_amount"   => 10.50,
            "id"                  => 987654321,
            "status_code"         => nil,
            "reason"              => "Example T-Shirt",
            "collector_id"        => 99678614,
            "date_created"        => "2012-05-05T14:22:43Z",
            "last_modified"       => "2012-05-05T14:35:13Z",
            "date_approved"       => "2012-05-05T14:22:43Z",
            "money_release_date"  => "2012-05-19T14:22:43Z",
            "released"            => "yes",
            "operation_type"      => "regular_payment",
            "payment_type"        => "credit_card",
            "site_id"             => "MLB"
          }
        }
      ],
      "paging" => {
        "total"   => 1,
        "limit"   => 30,
        "offset"  => 0
      }
    }

And the parameters thay could be used in the search hash are:

    id: Payment identifier
    site_id: Country identifier: Argentina: MLA; Brasil: MLB.
    date_created: Creation date. Ej: range=date_created&begin_date=NOW-1DAYS&end_date=NOW (Ver ISO-8601).
    date_approved: Approval date. Ej: range=date_approved&begin_date=NOW-1DAYS&end_date=NOW (Ver ISO-8601).
    last_modified: Last modified date. Ej: range=last_modified&begin_date=NOW-1DAYS&end_date=NOW (Ver ISO-8601).
    money_release_date: Date of the payment's release. Ej: range=money_release_date&begin_date=NOW-1DAYS&end_date=NOW (Ver ISO-8601).
    payer_id: Buyer's identifier.
    reason: Description of what's being payed.
    transaction_amount: Amount of the transaction.
    currency_id: Currency type. Argentina: ARS (peso argentino); USD (Dólar estadounidense); Brasil: BRL (Real).
    external_reference: Field used by the seller as aditional reference.
    mercadopago_fee: MercadoPago's comission fee.
    net_received_amount: Amount payable to the seller without mercadopago_fee.
    total_paid_amount: Obtained by adding: transaction_amount, shipping_cost and the amount payed by the buyer (including credit card's financing).
    shipping_cost: Shipping cost.
    status:
        pending: The payment process is incomplete.
        approved: The payment has been credited.
        in_process: The payment is under review.
        rejected: The payment has been rejected.
        cancelled: The payment is canceled after timeout or by either party.
        refunded: The payment has been refunded.
        in_mediation: The payment is in dispute.
    status_detail: Payment status detail.
    released: When the amount is available or not. Possible values are yes or no.
    operation_type:
        regular_payment: A payment.
        money_transfer: A money wire.
        recurring_payment: Active subscription recurring payment.
        subscription_payment: Subscription fee.

### Sandbox mode

The sandbox mode can be enabled/disabled as follows:

    mp_client.sandbox_mode(true)  # Enables sandbox
    mp_client.sandbox_mode(false) # Disables sandbox

### Recurring Payment Creation

Your request will need a hash to explain what the recurring payment is for. For example:

    data = {
      payer_email:        "xxx@test.com",
      back_url:           "http://www.site.com/return",
      reason:             "Monthly Magazine",
      external_reference: "OPERATION-ID-1234",
      auto_recurring: {
        frequency:          1,
        frequency_type:     "months",
        transaction_amount: 12.55,
        currency_id:        "BRL"
      }
    }

If everything worked out alright, you will get a response like this:

    {
       "id"                 => "f8ad8asd8asd98asd89add980",
       "payer_id"           => 131231333,
       "payer_email"        => "xxx@test.com",
       "back_url"           => "http://www.site.com/return",
       "collector_id"       => 3131231231,
       "application_id"     => 83818921839,
       "status"             => "authorized",
       "reason"             => "Monthly Magazine",
       "external_reference" => "OPERATION-ID-1234",
       "date_created"       => "2014-08-03T20:47:53.970-04:00",
       "last_modified"      => "2014-08-03T20:51:00.264-04:00",
       "init_point"         => "https://www.mercadopago.com/mlb/debits/new?preapproval_id=8ad8asd8ada8da8dad88sa",
       "auto_recurring" => {
        "frequency"          => 1,
        "frequency_type"     => "months",
        "transaction_amount" => 12.55,
        "currency_id"        => "BRL"
       }
    }


### Recurring Payment Status Verification Next Recurring Payments by IPN

To check the recurring payment status you will need the preapproval ID next recurring payments. Only then you can call the [MercadoPago IPN](https://developers.mercadopago.com/beta/documentacao/notificacoes-de-pagamentos#!/get-preapproval).

    # Use the preapproval ID received on the IPN.
    preapproval_id = '987654321'

    notification = mp_client.notification_authorized(preapproval_id)

You will get a response like this one:

Status code: 200 OK

    {
        "preapproval_id":     "preapproval_id",
        "id":                 "authorized_payment_id",
        "type":               "online",
        "status":             "processed",
        "date_created":       "2014-05-22T11:53:37.074-04:00",
        "last_modified":      "2014-05-22T11:53:37.074-04:00",
        "transaction_amount": 150,
        "currency_id":        "BRL",
        "payment":
        {
            "id":            "payment_id",
            "status":        "approved",
            "status_detail": "accredited"
        }
    }

### Recurring Payment Status Verification by IPN

To check the recurring payment status you will need the preapproval ID. Only then you can call the [MercadoPago IPN](https://developers.mercadopago.com/beta/documentacao/notificacoes-de-pagamentos#!/get-preapproval).

    # Use the preapproval ID received on the IPN.
    preapproval_id = '987654321'

    notification = mp_client.notification_preapproval(preapproval_id)

You will get a response like this one:

Status code: 200 OK

    {
      "id":                 "preapproval_id",
      "payer_id":           12345,
      "payer_email":        "payeremail@email.com",
      "back_url":           "https://www.mysite.com/afterAuth",
      "collector_id":       12345,
      "application_id":     10648,
      "status":             "authorized",
      "init_point":         "https://www.mercadopago.com/mlb/debits/new?preapproval_id=preapproval_id",
      "sandbox_init_point": "https://www.mercadopago.com/mlb/debits/new?preapproval_id=preapproval_id",
      "external_reference": "OP-1234",
      "reason":             "Detailed description about your service",
      "auto_recurring": {
        "frequency":          1,
        "frequency_type":     "months",
        "transaction_amount": 60,
        "currency_id":        "BRL"
      },
      "date_created":  "2012-08-31T11:50:26.648-04:00",
      "last_modified": "2012-08-31T11:50:26.648-04:00"
    }



### Errors

Errors will also be hashes with status code, message and error key.

For example, if you request payment method status for an invalid operation, you will see something like this:

    {
     "message"  => "Resource not found",
     "error"    => "not_found",
     "status"   => 404,
     "cause"    => []
    }

### Tests

This gem has tests for a few methods. To check if it is working properly, just run:

    rake test

Changelog
---------

2.2.0 (thanks gulymaestro)

Added support to the sandbox mode.

2.1.0 (thanks jamessonfaria)

Added functionality to create and get recurring payments. Also added support for recurring payments notification.

2.0.2

Request uses Faraday HTTP client instead of RestClient for better SSL support.

2.0.1

Added the refresh_access_token method to the authentication module.

2.0.0 (thanks leanucci and cavi21)

Implemented basic access to the collection search method. Changed the test credentials. Using Ruby 1.9 hash format. Added documentation for collection search.

1.0.2

Changed documentation according to the new client intercace, added a notification method to the client and added a new test.

1.0.1 (thanks etagwerker)

Added client interface, renamed "Mercadopago" to "MercadoPago", translated project summary to English and added tests for a few methods.

0.0.1

First release. It's possible to authenticate with the MercadoPago APIs, create payments and check payment status.

Copyright
---------

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
