module BarnyardHarvester
  class Queue

    def initialize(args)

      @debug = args.fetch(:debug) { false }

      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @my_id = "#{args[:crop_number]}-#{self.class}"

      @queue = Hash.new

    end

    def push(harvester_uuid, crop_change_uuid, crop_number, primary_key, transaction_type, value, old_value=Hash.new)
      check_key primary_key

      @queue[primary_key] = value.to_json

      @log.debug "HashQueue: Now: #{DateTime.now}, Harvester:#{harvester_uuid}, Change:#{crop_change_uuid} crop_number: #{crop_number}, key: #{primary_key}, transaction_type: #{transaction_type})"

    end

    def flush
      File.open("#{@my_id}.yml", "w") { |file| file.puts(@queue.to_yaml) }
    end

    private

    def check_key(primary_key)
      # Raise an exception here if the key must conform to a specific format
      # Example: raise "key must be a string object" unless key.is_a? String
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