# frozen_string_literal: true
# Main class
#
# example:
# class Application
#   # internal
#
#   def assign_card(user)
#     MandarinApi.new(credentials).assign_card(user)
#   end
#
#   def pay(result)
#     MandarinApi.new(credentials).pay(result.client, result.amount)
#   end
#
#   def notify_reject_payment(result)
#     UserNotificator.notify(result.user, result.reason)
#   end
#
#   def transit(request)
#     MandarinApi.new(credentials)
#                .process_callback(request, ResponseHandler.new)
#   end
#
#   class ResponseHandler
#     def success(result)
#       ResultProcessor.succes(result)
#     end
#
#     def failure(result)
#       ResultProcessor.failure(result)
#     end
#   end
#
#   class ResultProcessor
#     def success(result)
#       pay(result)
#     end
#
#     def failure(result)
#       reject_payment(result)
#     end
#   end
# end
require 'dry-configurable'
# Main module
module MandarinApi
  class << self
    attr_accessor :config
  end
  def self.assign_card(user)
    MandarinApi::CardManager.new.assign_card user
  end

  def self.pay(_client, _amount)
    # call api
  end

  def self.payout(order_id, amount, assigned_card_uuid)
    params = {
      order_id: order_id, amount: amount,
      assigned_card_uuid: assigned_card_uuid
    }
    MandarinApi::PaymentManager.new.perform_payout params
  end

  def self.process_callback(request_params, response_handler)
    response = MandarinApi::Responder.new.process(request_params)
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
