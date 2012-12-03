require "barnyard_market/version"
require "barnyard_ccfeeder"
require "barnyard_harvester"
require "crack"
require "aws-sdk"
require "uuid"
require "json"
require "bunny"

module BarnyardMarket

  class ProcessSubscriptions

    def initialize(args)

      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @cachecow_settings = args.fetch(:cachecow_settings) { raise "You must provide :cachecow_settings" }

      @cachecow = BarnyardCcfeeder::CacheCow.new(@cachecow_settings)

      @q = BarnyardHarvester::GenericQueue.new(args)

      deliver_subscriptions
    end

    def deliver_subscriptions

      count = 0


      while (msg = @q.pop(BarnyardHarvester::QUEUE_FARMER)) do

        count += 1

        payload = Crack::JSON.parse(msg)

        @log.info "#{count} Received #{payload["transaction_type"].upcase} for crop #{payload["crop_number"]}"

        subscribed = @cachecow.has_subscribers(payload["crop_number"])

        @log.info "#{subscribed.count} subscriptions for crop #{payload["crop_number"]}"

        subscribed.each do |subscription|

          queue_name = "#{BarnyardHarvester::QUEUE_TRANSACTION}-subscriber-#{subscription["subscriber"]["id"]}-crop-#{subscription["crop"]["crop_number"]}"

          payload["subscription_id"] = subscription["id"]
          payload["transaction_uuid"] = UUID.new.generate

          @log.info "Sending message for change #{payload["change_uuid"]} to queue #{queue_name}"
          json_payload = payload.to_json

          @q.push(queue_name, json_payload)
          @q.push(BarnyardHarvester::QUEUE_TRANSACTION, json_payload)

        end

      end

    end

  end

end

