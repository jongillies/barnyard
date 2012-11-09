#!/usr/bin/env ruby

require 'crack'
require 'json'

module Harvester

  class Barn

    def initialize(args)

      @crop_number = args.fetch(:crop_number) { raise "You must provide :crop_number" }
      @redis_settings = args.fetch(:redis_settings) { DEFAULT_REDIS_SETTINGS }
      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @my_id = "#{args[:crop_number]}-#{self.class}"
      @barn = Hash.new

      # Setup data source connection
      begin
        @barn = YAML::load_file("#{@my_id}.yml")
      rescue
      end
    end

    def log_run(harvester_uuid, crop_number, began_at, ended_at, source_count, change_count, add_count, delete_count)
      puts "HARVESTER_LOG #{harvester_uuid}, #{crop_number}, #{began_at}, #{ended_at}, #{source_count}, #{change_count}, #{add_count}, #{delete_count})"
    end

    def delete(primary_key)
      check_key primary_key
      object = Crack::JSON.parse(@barn[primary_key])
      @barn.delete primary_key
      object # Return the object
    end

    def []= primary_key, object
      check_key primary_key
      check_object object

      @barn[primary_key]= object.to_json
    end

    def [] primary_key
      check_key primary_key

      Crack::JSON.parse(@barn[primary_key])
    end

    def has_key?(primary_key)
      check_key primary_key

      if @barn.has_key? primary_key
        Crack::JSON.parse(@barn[primary_key])
      else
        nil
      end
    end

    def each
      @barn.each do |primary_key, value|
        yield primary_key, Crack::JSON.parse(value)
      end
    end

    def flush
      File.open("#{@my_id}.yml", "w") { |file| file.puts(@barn.to_yaml) }
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