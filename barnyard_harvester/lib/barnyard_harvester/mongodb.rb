require "mongo"
require "crack"
require "json"
require "resque"
require "barnyard_harvester/mongodb_helper"

#
#require "lib/barnyard_harvester/mongodb_helper"

module BarnyardHarvester

  DEFAULT_MONGO_SETTINGS = {
      :host_list => "localhost:27017",
      :collection => "test_collection",
      :db => "test_db"
  }

  class Barn

    def initialize(args)

      @crop_number = args.fetch(:crop_number) { raise "You must provide :crop_number" }
      @redis_settings = args.fetch(:redis_settings) { DEFAULT_REDIS_SETTINGS }
      @mongodb_settings = args.fetch(:mongodb_settings) { MongoSettings }
      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @mongodb_settings.fetch(:db) { raise "You must provide :db" }
      @mongodb_settings.fetch(:collection) { raise "You must provide :collection" }

      @redis_settings.delete(:db)
      Resque.redis = Redis.new(@redis_settings)

      @mongodb_settings[:debug] = @debug
      @mongodb_settings[:logger] = @log

      @mongo = BarnyardHarvester::MongoDbHelper.connect @mongodb_settings

      @collection_name = @mongodb_settings[:collection]
      @collection = @mongo.collection(@mongodb_settings[:collection])

      @collection
    end

    def log_run(harvester_uuid, crop_number, began_at, ended_at, source_count, change_count, add_count, delete_count)

      begin
        Resque.enqueue(HarvesterLogs, Time.now, harvester_uuid, crop_number, began_at, ended_at, source_count, change_count, add_count, delete_count)
      rescue Exception => e
        logger.fatal "#{self.class} Fail in Resque.enqueue of HarvesterLogs. #{e.backtrace}"
      end

    end

    def delete(primary_key)
      check_key primary_key

      value = @collection.find "_id" => primary_key # Save the value

      @collection.remove("_id" => primary_key)

      value.to_json # Return the object
    end

    def []= primary_key, object
      check_key primary_key
      check_object object

      obj = Crack::JSON.parse object.to_json

      # We artificially add the _id value to the object as this is the primary key
      # This is stored in the Mongo database, but removed upon a fetch.

      if obj.is_a?(Hash)
        obj["_id"] = primary_key
      else
        @log.fatal "WOAH! Class: #{object.class} Value: #{object}"
        return
      end


      if self.has_key? primary_key
        @collection.update({"_id" => primary_key}, obj)
      else
        @collection.insert obj
      end

    end

    def [] primary_key
      check_key primary_key

      doc = @collection.find("_id" => primary_key).to_a[0]

      #
      # Delete the "_id" from the document as it is artificial for the MongoDB primary key
      doc.delete("_id")

      Crack::JSON.parse(doc.to_json)
    end

    def has_key?(primary_key)
      check_key primary_key

      doc = @collection.find "_id" => primary_key
      if  doc.count == 0
        false
      else
        true
      end
    end

    def each

      collection = @mongo.collection(@collection_name)

      collection.find.each do |row|
        yield row["_id"], row.to_json
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