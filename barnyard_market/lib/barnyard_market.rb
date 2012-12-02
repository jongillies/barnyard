require "barnyard_market/version"
require "barnyard_ccfeeder"
require "barnyard_harvester"
require "crack"
require "aws-sdk"
require "uuid"
require "json"
require "bunny"

module BarnyardMarket
  class Queue

    def initialize(args)
      @queueing = args.fetch(:queueing) { raise "You must provide :queueing" }

      case @queueing
        when :sqs
          @sqs_settings = args.fetch(:sqs_settings) { raise "You must provide :sqs_settings" }
          @sqs = AWS::SQS.new(@sqs_settings)
        when :rabbitmq
          @rabbitmq_settings = args.fetch(:rabbitmq_settings) { raise "You must provide :rabbitmq_settings" }
          @rabbitmq_settings[:logging] = true if @debug
          @bunny = Bunny.new(@rabbitmq_settings)
          @bunny.start
        else
          raise "Unknown queueing method."
      end

    end

    def send(name, message)
      case @queueing
        when :sqs
          queue = @sqs.queues.create(name)
          queue.send_message(message)
        when :rabbitmq
          @bunny.queue(name).publish(message)
      end
    end

    def get(name)
      case @queueing
        when :sqs
          @sqs.queues.create(name).receive_message
        when :rabbitmq
          msg = @bunny.queue(name).pop[:payload]
          if msg == :queue_empty
            return nil
          else
            msg
          end
      end
    end

    def delete(msg)
      case @queueing
        when :sqs
          msg.delete
      end

    end

  end

  class ProcessSubscriptions

    def initialize(args)

      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @cachecow_settings = args.fetch(:cachecow_settings) { raise "You must provide :cachecow_settings" }

      @cachecow = BarnyardCcfeeder::CacheCow.new(@cachecow_settings)

      @q = Queue.new(args)

      deliver_subscriptions
    end

    def deliver_subscriptions

      count = 0

      while (msg = @q.get("barnyard-farmer")) do

        count += 1

        payload = Crack::JSON.parse(msg)

        @log.info "#{count} Received #{payload["transaction_type"].upcase} for crop #{payload["crop_number"]}"

        subscribed = @cachecow.has_subscribers(payload["crop_number"])

        @log.info "#{subscribed.count} subscriptions for crop #{payload["crop_number"]}"

        subscribed.each do |subscription|

          queue_name = "barnyard-transactions-subscriber-#{subscription["subscriber"]["id"]}-crop-#{subscription["crop"]["crop_number"]}"

          payload["subscription_id"] = subscription["id"]
          payload["transaction_uuid"] = UUID.new.generate

          @log.info "Sending message for change #{payload["change_uuid"]} to queue #{queue_name}"
          json_payload = payload.to_json

          @q.send(queue_name, json_payload)
          @q.send("barnyard-transaction", json_payload)

        end

        @q.delete(msg)

      end

    end

  end

end

