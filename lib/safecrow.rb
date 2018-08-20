require 'json'
require 'curb'
require 'openssl'
require "safecrow/version"
require "safecrow/configuration"

module Safecrow
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.set_settings(url)
    endpoint = '/settings'
    payload = {callback_url: url}
    make_request(endpoint, payload, 'POST')
  end

  # return id
  def self.create_user(email, phone, name)
    endpoint = '/users'
    payload = { email: email, phone: phone.delete('(').delete(')').delete('-').delete(' '), name: name }
    make_request(endpoint, payload, 'POST')['id']
  end

  # return id
  def self.find_user(email)
    endpoint = "/users?email=#{email}"
    (make_request(endpoint, {}, 'GET').first || {})['id']
  end

  def self.get_user_by_id(sc_user_id)
    endpoint = "/users/#{sc_user_id}"
    make_request(endpoint, {}, 'GET')
  end

  # return id
  def self.edit_user(sc_id, phone, name)
    endpoint = "/users/#{sc_id}"
    payload = { phone: phone.delete('(').delete(')').delete('-').delete(' '),
                name: name }
    make_request(endpoint, payload, 'POST')['id']
  end

  # return "redirect_url"
  def self.add_card(user_id, url)
    endpoint = "/users/#{user_id}/cards"
    payload = { redirect_url: url }
    make_request(endpoint, payload, 'POST')['redirect_url']
  end

  # return [{ number: '', id: '' }]
  def self.get_user_cards(user_id)
    endpoint = "/users/#{user_id}/cards"
    make_request(endpoint, {}, 'GET').map do |card|
      { number: card['card_number'], id: card['id'] }
    end
  end

  # return {"price"=>123, "supplier_service_cost"=>4, "consumer_service_cost"=>0}
  def self.calculate(price)
    endpoint = '/calculate'
    payload = {
        price: price,
        service_cost_payer: 'supplier',
        #consumer_cancellation_cost: 0
    }
    make_request(endpoint, payload, 'POST')
  end

  # return id
  def self.create_order(consumer_id, supplier_id, price, delivery_cost, delivery_cost_payer = 'consumer')
    endpoint = '/orders'
    payload = {
        consumer_id: consumer_id,
        supplier_id: supplier_id,
        price: price*100, # в копьях
        description: 'description',
        service_cost_payer: 'supplier',
        delivery_cost: delivery_cost*100,
        delivery_cost_payer: delivery_cost_payer,
    }
    make_request(endpoint, payload, 'POST')['id']
  end
  # return {"id"=>9529, "consumer_id"=>4315, "supplier_id"=>4315, "price"=>45000, "consumer_service_cost"=>0, "supplier_service_cost"=>1800, "consumer_delivery_cost"=>0, "supplier_delivery_cost"=>0, "consumer_cancellation_cost"=>0, "discount"=>0, "description"=>"description", "status"=>"pending", "supplier_payout_method_id"=>1748, "supplier_payout_method_type"=>"CreditCard", "created_at"=>"2018-07-13T11:18:25+03:00", "updated_at"=>"2018-07-13T11:21:59+03:00", "extra"=>{}}
  def self.get_order(order_id)
    endpoint = "/orders/#{order_id}"
    make_request(endpoint, {}, 'GET')
  end

  # return some array with hashes with ids and etc...
  def self.get_orders(user_id)
    endpoint = "/users/#{user_id}/orders"
    make_request(endpoint, {}, 'GET')
  end

  # return some hash with ids and etc...
  def self.annul_order(order_id, reason = 'Some reason')
    endpoint = "/orders/#{order_id}/annul"
    payload = { reason: reason }
    make_request(endpoint, payload, 'POST')
  end

  # return payment_url
  def self.pay_order(order_id, redirect_url)
    endpoint = "/orders/#{order_id}/pay"
    payload = { redirect_url: redirect_url }
    make_request(endpoint, payload, 'POST')['payment_url']
  end

  # return "redirect_url"
  def self.payout_card(user_id, order_id, supplier_payout_card_id)
    endpoint = "/users/#{user_id}/orders/#{order_id}"
    payload = { supplier_payout_card_id: supplier_payout_card_id }
    make_request(endpoint, payload, 'POST')
  end

  # return some hash with ids and etc...
  def self.cancel_order(order_id, reason = 'Some reason')
    endpoint = "/orders/#{order_id}/cancel"
    payload = { reason: reason }
    make_request(endpoint, payload, 'POST')
  end

  # return some hash with ids and etc...
  def self.close_order(order_id, reason = 'Some reason', discount = 0)
    endpoint = "/orders/#{order_id}/close"
    payload = {
        reason: reason,
        discount: discount*100
    }
    make_request(endpoint, payload, 'POST')
  end

  # return some hash with ids and etc...
  def self.escalate_order(order_id, reason = 'Some reason')
    endpoint = "/orders/#{order_id}/escalate"
    payload = { reason: reason }
    make_request(endpoint, payload, 'POST')
  end

  # return {"redirect_url"=>"", "consumer_pay"=>10000}
  def self.preauth_order(order_id, redirect_url)
    endpoint = "/orders/#{order_id}/preauth"
    payload = { redirect_url: redirect_url }
    make_request(endpoint, payload, 'POST')
  end

  def self.confirm_preauth(order_id, reason = 'Some reason')
    endpoint = "/orders/#{order_id}/preauth/confirm"
    payload = { reason: reason }
    make_request(endpoint, payload, 'POST')
  end

  def self.release_preauth(order_id, reason = 'Some reason')
    endpoint = "/orders/#{order_id}/preauth/release"
    payload = { reason: reason }
    make_request(endpoint, payload, 'POST')
  end

  private

  def self.log(data)
    puts data
  end

  def self.auth(endpoint, data)
    c = Curl::Easy.new(Safecrow.configuration.url + Safecrow.configuration.prefix + endpoint)
    c.headers['Content-Type'] = 'application/json'
    c.http_auth_types = :basic
    c.username = Safecrow.configuration.apikey
    c.password = OpenSSL::HMAC.hexdigest('SHA256', Safecrow.configuration.apisecret, data)
    c
  end

  def self.make_request(endpoint, payload, method)
    data = Safecrow.configuration.apikey + method + Safecrow.configuration.prefix + endpoint + proceed_payload(payload)
    c = auth(endpoint, data)
    case method
    when 'GET'
      c.perform
    when 'POST'
      c.post(proceed_payload(payload))
    else
      raise ArgumentError, "undefined method #{method}"
    end
    log(endpoint)
    log(c.status)
    log(c.body)
    raise c.status + c.body if c.status != '200 OK'
    JSON.parse(c.body)
  end

  def self.proceed_payload(payload)
    if payload.empty?
      ''
    else
      payload.to_json
    end
  end
end
