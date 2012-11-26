require "redis"
require "crack"
require "json"
require "resque"

module BarnyardHarvester

  class Barn

    def initialize(args)

      @crop_number = args.fetch(:crop_number) { raise "You must provide :crop_number" }
      @redis_settings = args.fetch(:redis_settings) { DEFAULT_REDIS_SETTINGS }
      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @redis_settings.delete(:db)

      #Resque.redis = Redis.new(@redis_settings)

      # This sets the database number for redis to store the cached data
      @redis_settings[:db] = args[:crop_number]

      # Connect to Redis
      @redis = Redis.new(@redis_settings)

    end

    def delete(primary_key)
      check_key primary_key

      value = @redis.get primary_key # Save the value
      @redis.del primary_key # Delete the key
      Crack::JSON.parse(value) # Return the object
    end

    def []= primary_key, object
      check_key primary_key
      check_object object

      @redis.set primary_key, object.to_json
    end

    def [] primary_key
      check_key primary_key

      Crack::JSON.parse(@redis.get primary_key)
    end

    def has_key?(primary_key)
      check_key primary_key

      if @redis.exists primary_key
        Crack::JSON.parse(@redis.get primary_key)
      else
        nil
      end
    end

    def each
      @redis.keys('*').each do |primary_key|
        yield primary_key, Crack::JSON.parse(@redis.get(primary_key))
      end
    end

    def flush
    end

    private

    def check_key(primary_key)
      # Raise an exception here if the key must conform to a specific format
      # Example: raise "key must be a string object" unless key.is_a? String
    end

    def check_object(object)
      raise "#{object.class} must implement the to_json method" unless object.respond_to? :to_json
    end
  end

end