
require "barnyard_harvester/generic_queue"

module BarnyardHarvester

  QUEUE_FARMER = "barnyard-farmer"
  QUEUE_HARVESTER = "barnyard-harvests"
  QUEUE_TRANSACTION = "barnyard-transactions"
  QUEUE_CHANGE = "barnyard-changes"

  class Queue

    def enqueue(queue, harvester_uuid, change_uuid, crop_number, primary_key, transaction_type, value, old_value)

      payload = Hash.new
      payload[:queued_at] = Time.now
      payload[:harvester_uuid] = harvester_uuid
      payload[:change_uuid] = change_uuid
      payload[:crop_number] = crop_number
      payload[:primary_key] = primary_key
      payload[:transaction_type] = transaction_type
      payload[:value] = value
      payload[:old_value] = old_value

      json_payload = payload.to_json

      @q.push(queue,json_payload)
      @q.push(QUEUE_CHANGE,json_payload)

    end

    def log_run(harvester_uuid, crop_number, began_at, ended_at, source_count, change_count, add_count, delete_count)

      payload = Hash.new
      payload[:time] = Time.now
      payload[:harvester_uuid] = harvester_uuid
      payload[:crop_number] = crop_number
      payload[:began_at] = began_at
      payload[:ended_at] = ended_at
      payload[:source_count] = source_count
      payload[:change_count] = change_count
      payload[:add_count] = add_count
      payload[:delete_count] = delete_count

      @q.push(QUEUE_HARVESTER,payload.to_json)

    end

    def initialize(args)

      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }
      @crop_number = args.fetch(:crop_number) { raise "You must provide :crop_number" }

      @q = BarnyardHarvester::GenericQueue.new(args)

    end

    def push(harvester_uuid, change_uuid, crop_number, primary_key, transaction_type, value, old_value=Hash.new)
      check_key primary_key

      enqueue(QUEUE_FARMER, harvester_uuid, change_uuid, crop_number, primary_key, transaction_type, value.to_json, old_value.to_json)

      message = "RabbitQueue: #{QUEUE_FARMER}, Now: #{DateTime.now}, Harvester:#{harvester_uuid}, Change:#{change_uuid} crop_number: #{crop_number}, key: #{primary_key}, transaction_type: #{transaction_type})"

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