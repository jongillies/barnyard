require "barnyard_logger/version"
require "barnyard_ccfeeder"
require "barnyard_harvester"
require "crack"
require "aws-sdk"
require "uuid"
require "json"
require "bunny"

module BarnyardLogger

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


  class Logs

    def initialize(args)

      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @cachecow_settings = args.fetch(:cachecow_settings) { raise "You must provide :cachecow_settings" }

      @cachecow = BarnyardCcfeeder::CacheCow.new(@cachecow_settings)

      @q = Queue.new(args)

      #@debug = args.fetch(:debug) { false }
      #@log = args.fetch(:logger) { Logger.new(STDOUT) }
      #
      #@sqs_settings = args.fetch(:sqs_settings) { raise "You must provide :sqs_settings" }
      #@dynamodb_settings = args.fetch(:dynamodb_settings) { raise "You must provide :dynamodb_settings" }
      #@cachecow_settings = args.fetch(:cachecow_settings) { raise "You must provide :cachecow_settings" }
      #
      #@cachecow = BarnyardCcfeeder::CacheCow.new(@cachecow_settings)
      #
      #@sqs = AWS::SQS.new(@sqs_settings)
      #
      #@changes_queue = @sqs.queues.create("barnyard-changes")
      #@transaction_queue = @sqs.queues.create("barnyard-transactions")
      #@harvests_queue = @sqs.queues.create("barnyard-harvests")

    end


    def process_harvests

      while (msg = @q.get("barnyard-harvests")) do

        payload = Crack::JSON.parse(msg)

        begin
          @cachecow.push_harvester_stats(payload['harvester_uuid'],
                                         payload['crop_number'],
                                         payload['began_at'],
                                         payload['ended_at'],
                                         payload['source_count'],
                                         payload['change_count'],
                                         payload['add_count'],
                                         payload['delete_count'])
          @q.delete(msg)

        rescue Exception => e
          $stderr.puts e
        end

      end

    end

    def process_changes

      while (msg = @q.get("barnyard-changes")) do

        payload = Crack::JSON.parse(msg)

        begin
          @cachecow.push_change(payload['queued_at'],
                                payload['harvester_uuid'],
                                payload['change_uuid'],
                                payload['crop_number'],
                                payload['primary_key'],
                                payload['transaction_type'],
                                payload['value'],
                                payload['old_value'])
          @q.delete(msg)

        rescue Exception => e
          $stderr.puts e
        end

      end
    end

    def process_transactions

      while (msg = @q.get("barnyard-transactions")) do

        payload = Crack::JSON.parse(msg)

        # subscription_id, queued_at, $change_uuid, $transaction_uuid
        begin
          @cachecow.push_transaction(payload['subscription_id'],
                                     payload['queued_at'],
                                     payload['change_uuid'],
                                     payload['transaction_uuid'])
          @q.delete(msg)

        rescue Exception => e
          $stderr.puts e
        end

      end

    end

  end
end




