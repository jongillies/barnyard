require "barnyard_logger/version"
require "barnyard_ccfeeder"
require "barnyard_harvester"
require "crack"
require "aws-sdk"
require "uuid"
require "json"
require "bunny"

module BarnyardLogger

  class Logs

    def initialize(args)

      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @cachecow_settings = args.fetch(:cachecow_settings) { raise "You must provide :cachecow_settings" }

      @cachecow = BarnyardCcfeeder::CacheCow.new(@cachecow_settings)

      @q = BarnyardHarvester::GenericQueue.new(args)

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

      while (msg = @q.pop("barnyard-harvests")) do

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

        rescue Exception => e
          $stderr.puts e
        end

      end

    end

    def process_changes

      while (msg = @q.pop("barnyard-changes")) do

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

        rescue Exception => e
          $stderr.puts e
        end

      end
    end

    def process_transactions

      while (msg = @q.pop("barnyard-transactions")) do

        payload = Crack::JSON.parse(msg)

        begin
          @cachecow.push_transaction(payload['subscription_id'],
                                     payload['queued_at'],
                                     payload['change_uuid'],
                                     payload['transaction_uuid'])

        rescue Exception => e
          $stderr.puts e
        end

      end

    end

  end
end




