module BarnyardHarvester

  require "bunny"

  QUEUE_FARMER = "barnyard-farmer"
  QUEUE_HARVESTER = "barnyard-harvests"
  QUEUE_TRANSACTION = "barnyard-transactions"
  QUEUE_CHANGE = "barnyard-changes"

  class Queue

    def enqueue(queue, queued_at, harvester_uuid, change_uuid, crop_number, primary_key, transaction_type, value, old_value)

      payload = Hash.new
      payload[:queued_at] = queued_at
      payload[:harvester_uuid] = harvester_uuid
      payload[:change_uuid] = change_uuid
      payload[:crop_number] = crop_number
      payload[:primary_key] = primary_key
      payload[:transaction_type] = transaction_type
      payload[:value] = value
      payload[:old_value] = old_value

      json_payload = payload

      @exchange.publish(json_payload, key: queue)
      @exchange.publish(json_payload, key: QUEUE_CHANGE)

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

      @exchange.publish(payload.to_json, key: QUEUE_HARVESTER)

    end

    def initialize(args)

      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }
      @crop_number = args.fetch(:crop_number) { raise "You must provide :crop_number" }
      @rabbitmq_settings = args.fetch(:rabbitmq_settings) { raise "You must provide :rabbitmq_settings" }

      @rabbitmq_settings[:logging] = true if @debug

      @bunny = Bunny.new(@rabbitmq_settings)
      @bunny.start
      @exchange = @bunny.exchange("")

    end

    def push(harvester_uuid, change_uuid, crop_number, primary_key, transaction_type, value, old_value=Hash.new)
      check_key primary_key

      enqueue(QUEUE_FARMER, DateTime.now, harvester_uuid, change_uuid, crop_number, primary_key, transaction_type, value.to_json, old_value.to_json)

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