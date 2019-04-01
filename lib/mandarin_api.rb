# frozen_string_literal: true
# Main module
module MandarinApi
  class << self
    attr_accessor :config
  end

  def self.assign_card(user, urls = {})
    MandarinApi::CardManager.new.assign_card user, urls
  end

  def self.oneway_assign_card(user, card)
    MandarinApi::CardManager.new.one_side_assign_card user, card
  end

  def self.charge(order_id, amount, user, extra = {})
    params = {
      order_id: order_id, amount: amount, email: user.email, phone: user.phone,
      urls: extra[:urls], custom_values: extra[:custom_values]
    }
    MandarinApi::PaymentManager.new.perform_charge params
  end

  def self.pay(order_id, amount, assigned_card_uuid, custom_values = [])
    params = {
      order_id: order_id, amount: amount, custom_values: custom_values,
      assigned_card_uuid: assigned_card_uuid
      # urls: extra[:urls]
    }
    MandarinApi::PaymentManager.new.perform_payment params
  end


  def self.payout(order_id, amount, assigned_card_uuid, customer_info, urls)
    params = {
      order_id: order_id, amount: amount,
      assigned_card_uuid: assigned_card_uuid,
      customer_info: customer_info,
      urls: urls
    }
    MandarinApi::PaymentManager.new.perform_payout params
  end

  def self.refund(order_id, transaction_uuid, amount, urls)
    params = {
      order_id: order_id,
      transaction_uuid: transaction_uuid,
      amount: amount,
      urls: urls
    }
    MandarinApi::PaymentManager.new.perform_refund params
  end

  def self.rebill(order_id, amount, transaction_uuid)
    params = { order_id: order_id, amount: amount, transaction_uuid: transaction_uuid }
    MandarinApi::PaymentManager.new.perform_rebill params
  end

  def self.preauth(order_id, amount, user, extra = {})
    params = {
      order_id: order_id, amount: amount, email: user.email, phone: user.phone,
      urls: extra[:urls], custom_values: extra[:custom_values]
    }
    MandarinApi::PaymentManager.new.perform_preauth params
  end

  def self.confirmauth(order_id, amount, user, transaction_uuid, urls = {})
    params = {
      order_id: order_id, amount: amount,
      urls: urls,
      email: user.email, phone: user.phone,
      transaction_uuid: transaction_uuid
    }
    MandarinApi::PaymentManager.new.perform_confirmauth params
  end

  def self.reversal(order_id, transaction_uuid, urls = {})
    params = {
      order_id: order_id, urls: urls,
      transaction_uuid: transaction_uuid
    }
    MandarinApi::PaymentManager.new.perform_reversal params
  end

  def self.perform_rebill_preauth(order_id, amount, user, assigned_card_uuid, extra = {})
    params = {
      order_id: order_id, amount: amount, email: user.email, phone: user.phone,
      assigned_card_uuid: assigned_card_uuid, urls: extra[:urls]
    }
    MandarinApi::PaymentManager.new.perform_rebill_preauth params
  end

  def self.process_callback(request_params, response_handler)
    response = MandarinApi::Responder.new(request_params)
    response_handler.success(response.data) if response.success
    response_handler.failure(response.data) if response.failure
  end

  def self.config
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(config)
  end
end

require 'mandarin_api/card_manager'
require 'mandarin_api/payment_manager'
require 'mandarin_api/responder'
require 'mandarin_api/wrapper'
require 'mandarin_api/configuration'
