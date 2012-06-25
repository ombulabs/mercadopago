MercadoPago
===========

Esta gem para Ruby é um cliente que permite que desenvolvedores acessem os serviços do http://www.mercadopago.com (MercadoPago).

Antes de começar a usá-la, é recomendável conhecer mais sobre as APIs do MercadoPago e ler as suas documentações. Como esta gem utiliza hashes para representar requests e responses, é necessário conhecer os parâmetros das APIs do MercadoPago para fazer as chamadas corretas e processar as respostas corretamente.

Para conhecer a documentação das APIs do MercadoPago, veja este link: https://developers.mercadopago.com/integracao-checkout

Instalação
----------

Você pode instalar a última versão da gem MercadoPago com o seguinte comando:

	gem install mercadopago
	
Você pode também adicionar a gem ao Gemfile do seu projeto:

	gem 'mercadopago'

Credenciais de acesso
---------------------

Para usar esta gem, é necessário fornecer o client_id e o client_secret da sua conta do MercaodPago. Esta gem não armazena estes dados sob nenhuma hipótese. Para consultar as suas credenciais no MercadoPago, acesse o link a seguir: https://www.mercadopago.com/mlb/ferramentas/aplicacoes

Exemplos
--------

### Autenticação
	
	# Use as suas credenciais.
	client_id = '1234'
	client_secret = 'abcdefghijklmnopqrstuvwxyz'
	
	access = MercadoPago::Authentication.access_token(client_id, client_secret)
	
A resposta desta requisição será um hash como o que segue:

	{
		"access_token" => "APP_USR-1234-999999-abcdefghijklmnopqrstuvwxyz-999999999",
		"token_type" => "bearer",
		"expires_in" => 10800,
		"scope" => "mclics_advertising offline_access read write",
		"refresh_token" => "TG-abcdefghijklmnopqrstuvwxyz"
	}
	
Você deverá usar o "access_token" nas demais requisições para outros webservices.

### Criação de pagamento

	data = {
		"external_reference" => "OPERATION-ID-1234",
		"items" => [
			{
				"id" => "Código 123",
				"title" => "Nome produto",
				"description" => "Descrição produto",
				"quantity" => 1,
				"unit_price" => 10.50,
				"currency_id" => "BRL",
				"picture_url" => "http://www.site.com.br/image/123.png"
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

	payment = MercadoPago::Checkout.create_preference(access_token, data)
	
Como resposta, será recebido um hash como o seguinte:

	{
		"payment_methods" => {},
		"init_point" => "https://www.mercadopago.com/mlb/checkout/pay?pref_id=abcdefgh-9999-9999-ab99-999999999999",
		"collector_id" => 123456789,
		"back_urls" => {
			"pending"=> "https://www.site.com.br/pending",
			"success"=> "http://www.site.com.br/success",
			"failure"=> "http://www.site.com.br/failure"
		},
		"sponsor_id" => nil,
		"expiration_date_from" => nil,
		"additional_info" => "",
		"marketplace_fee" => 0,
		"date_created" => "2012-05-07T20:07:52.293-04:00",
		"subscription_plan_id" => nil,
		"id"=> "abcdefgh-9999-9999-ab99-999999999999",
		"expiration_date_to" => nil,
		"expires" => false,
		"external_reference" => "OPERATION-ID-1234",
		"payer" => {
			"email" => "comprador@email.com.br",
			"name" => "João",
			"surname" => "Silva"
		},
		"items" => [
			{
				"id" => "Código 123",
				"currency_id" => "BRL",
				"title" => "Nome produto",
				"picture_url" => "http://www.site.com.br/image/123.png",
				"description" => "Descrição produto",
				"quantity" => 1,
				"unit_price" => 10.50
			}
		],
		"client_id" => "963",
		"marketplace" => "NONE"
	}

### Verificação de status de pagamento

Para consultar o status de um pagamento é necessário ter o id associado a ele, o qual é recebido na IPN do MercadoPago.

	# Use o id do pagamento recebido na IPN do MercadoPago.
	payment_id = '987654321'

	notification = MercadoPago::Collection.notification(access_token, payment_id)
	
Será retornado um hash similar ao seguinte:

	{
		"collection" => {
			"id" => 987654321,
			"site_id" => "MLB",
			"operation_type" => "regular_payment",
			"order_id" => nil,
			"external_reference" => "OPERATION-ID-1234",
			"status" => "approved",
			"status_detail" => "approved",
			"payment_type" => "credit_card",
			"date_created" => "2012-05-05T14:22:43Z",
			"last_modified" => "2012-05-05T14:35:13Z",
			"date_approved" => "2012-05-05T14:22:43Z",
			"money_release_date" => "2012-05-19T14:22:43Z",
			"currency_id" => "BRL",
			"transaction_amount" => 10.50,
			"shipping_cost" => 0,
			"total_paid_amount" => 10.50,
			"finance_charge" => 0,
			"net_received_amount" => 0,
			"marketplace" => "NONE",
			"marketplace_fee" => nil,
			"reason" => "Nome produto",
			"payer" => {
				"id" => 543219876,
				"first_name" => "João",
				"last_name" => "Silva",
				"nickname" => "JOAOSILVA",
				"phone" => {
					"area_code" => nil,
					"number" => "551122334455",
					"extension" => nil
				},
				"email" => "comprador@email.com.br",
				"identification" => {
					"type" => nil,
					"number" => nil
				}
			},
			"collector" => {
				"id" => 123456789,
				"first_name" => "Manoel",
				"last_name" => "Recebedor",
				"phone" => {
					"area_code" => nil,
					"number" => "1122334455",
					"extension" => nil
				},
				"email" => "recebedor@email.com.br",
				"nickname" => "MANOELRECEBEDOR"
			}
		}
	} 


### Erros

Os erros retornados por esta gem são hashes quem contém os dados recebidos dos webservices do MercadoPago.

Por exemplo, caso seja requisitado um access_token através da credenciais inválidas, um hash de erro como o seguinte será retornado:

	{
		"message" => "client_id[1,234] o client_secret[abcdefghijklmnopqrstuvwxyz] inválidos",
		"error" => "invalid_client",
		"status" => 400,
		"cause" => []
	}
