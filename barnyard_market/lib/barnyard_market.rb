require "barnyard_market/version"

require "ccfeeder"

module BarnyardMarket
  class DeliverSubscriptions

    def initialize(args)

      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @sqs_settings = args.fetch(:sqs_settings) { raise "You must provide :sqs_settings" }
      @dynamodb_settings = args.fetch(:dynamodb_settings) { raise "You must provide :dynamodb_settings"  }
      @cachecow_settings = args.fetch(:cachecow_settings) { raise "You must provide :cachecow_settings"  }

      @cachecow = CcFeeder::CacheCow.new(@cachecow_settings)

    end


    def do_it

      Helper::LOG.info("#{self.name} GOT: #{queued_at}, harvester_uuid: #{harvester_uuid}, crop_number: #{crop_number}, primary_key: #{primary_key}, transaction_type: #{transaction_type}, value: #{value}, old_value: #{old_value}")

      Helper::COW.subscriptions.each do |subscription_id, subscription|

        unless subscription["active"] == true
          Helper::LOG.info("Subscription #{subscription_id} is not active.")
          next
        end

        if Helper::COW.crops[subscription["crop_id"]]["crop_number"] == crop_number

          transaction_uuid = UUID.new.generate

          Object.const_set("Deliver", Class.new { @queue = "Tractor-#{subscription_id}" })

          Resque.enqueue(Deliver, subscription_id, queued_at, change_uuid, transaction_uuid, crop_number, primary_key, transaction_type, value, old_value)

          Resque.enqueue(TransactionLogs, subscription_id, queued_at, change_uuid, transaction_uuid, crop_number, primary_key, transaction_type, value, old_value)

          #@d.push subscription_id, queued_at, change_uuid, UUID.new.generate, crop_number, primary_key, transaction_type, value, old_value

        end
      end

    end


    h = BarnyardMarket::DeliverSubscriptions.new(:queueing => :sqs,
                                                 :sqs_settings => SQS_SETTINGS,
                                                 :backend => backend,
                                                 :debug => true,
                                                 :dynamodb_settings => DEFAULT_DYNAMODB_SETTINGS,
                                                 :logger => my_logger)


  end
end
