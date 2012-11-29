require "barnyard_market/version"
require "barnyard_ccfeeder"
require "barnyard_harvester"
require "crack"
require "aws-sdk"
require "uuid"
require "json"

module BarnyardMarket
  class ProcessSubscriptions

    def initialize(args)

      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @sqs_settings = args.fetch(:sqs_settings) { raise "You must provide :sqs_settings" }
      @dynamodb_settings = args.fetch(:dynamodb_settings) { raise "You must provide :dynamodb_settings" }
      @cachecow_settings = args.fetch(:cachecow_settings) { raise "You must provide :cachecow_settings" }

      @cachecow = BarnyardCcfeeder::CacheCow.new(@cachecow_settings)

      @sqs = AWS::SQS.new(@sqs_settings)

      @farmer_queue = @sqs.queues.create("barnyard-farmer")
      @transaction_queue = @sqs.queues.create("barnyard-transactions")

      deliver_subscriptions
    end


    def deliver_subscriptions

      while (msg = @farmer_queue.receive_message) do

#        begin
          payload = Crack::JSON.parse(msg.body)

          @log.info "Received #{payload["transaction_type"].upcase} for crop #{payload["crop_number"]}"

          subscribed = @cachecow.has_subscribers(payload["crop_number"])

          @log.info "#{subscribed.count} subscriptions for crop #{payload["crop_number"]}"

          subscribed.each do |subscription_id, subscription|

            #puts "Subscription ID: #{id}"
            #puts "Subscriber   ID: #{subscription["subscriber"]["id"]}"
            #puts "Crop Number    : #{subscription["crop"]["id"]}"

            queue_name = "barnyard-transactions-subscriber-#{subscription["subscriber"]["id"]}-crop-#{subscription["crop"]["id"]}"
            queue = @sqs.queues.create(queue_name)

            payload["subscription_id"] = subscription_id
            payload["transaction_uuid"] = UUID.new.generate

            @log.info "Sending message to queue #{queue_name}"
            json_payload = payload.to_json
            queue.send_message(json_payload)
            @transaction_queue.send_message(json_payload)
          end

          msg.delete

#        rescue e
#          $stderr.puts e
#        end

      end

    end
  end
end

