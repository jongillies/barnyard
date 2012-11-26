module BarnyardHarvester

  class ChangeLogs
    @queue = :logs_change
  end

  class HarvesterLogs
    @queue = :logs_harvester
  end

  class DeliveryLogs
    @queue = :logs_delivery
  end

  class TransactionLogs
    @queue = :logs_transaction
  end
  class Queue

    class Enqueue
      def initialize(queue, queued_at, harvester_uuid, crop_change_uuid, crop_number, primary_key, transaction_type, value, old_value)
        Resque.enqueue(queue, queued_at, harvester_uuid, crop_change_uuid, crop_number, primary_key, transaction_type, value, old_value)
        Resque.enqueue(ChangeLogs, queued_at, harvester_uuid, crop_change_uuid, crop_number, primary_key, transaction_type, value, old_value)
      end
    end

    def log_run(harvester_uuid, crop_number, began_at, ended_at, source_count, change_count, add_count, delete_count)

      Resque.enqueue(HarvesterLogs, harvester_uuid, crop_number, began_at, ended_at, source_count, change_count, add_count, delete_count)

    end

    def initialize(args)

      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }
      @crop_number = args.fetch(:crop_number) { raise "You must provide :crop_number" }

      resque_class_name = "Distribute"

      # If the class does not exist, the rescue block will create it.
      # The Class Queue is inherited by the AddQueue, ChangeQueue and DeleteQueue, but
      # we only want to create one "resque" queue for this instantiation
      begin
        Object.const_get(resque_class_name)
      rescue
        # Set the queue name to this apol_harvester's id prefixed with a Q_
        #Object.const_set(resque_class_name, Class.new { @queue =  "Q_#{args[:crop_number]}"})
        Object.const_set(resque_class_name, Class.new { @queue = "Farmer" })
      end

      @resque_queue = Object.const_get(resque_class_name)

    end


    def push(harvester_uuid, crop_change_uuid, crop_number, primary_key, transaction_type, value, old_value=Hash.new)
      check_key primary_key

      Enqueue.new(@resque_queue, DateTime.now, harvester_uuid, crop_change_uuid, crop_number, primary_key, transaction_type, value.to_json, old_value.to_json)

      message = "RedisQueue: #{@resque_queue}, Now: #{DateTime.now}, Harvester:#{harvester_uuid}, Change:#{crop_change_uuid} crop_number: #{crop_number}, key: #{primary_key}, transaction_type: #{transaction_type})"

      if @log.level == Logger::DEBUG
        message += ", value: #{value.to_json}, old_value: #{old_value.to_json}"
        @log.debug message
      end
    end

    # Flush any data if needed.
    #
    def flush
    end

    private

    # Raise an exception here if the key must conform to a specific format
    #
    def check_key(primary_key)
      # Example: raise "key must be a string object" unless key.is_a? String
      primary_key
    end

  end

  # AddQueue
  #
  class AddQueue < Queue
  end

  # ChangeQueue
  #
  class ChangeQueue < Queue
  end

  # DeleteQueue
  #
  class DeleteQueue < Queue
  end

end