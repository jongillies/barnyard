require "uuid"
require "logger"

require "barnyard_harvester/version"
require "barnyard_harvester/queue"

module BarnyardHarvester

  ADD = "add"
  CHANGE = "change"
  DELETE = "delete"

  DEFAULT_REDIS_SETTINGS = {:host => "localhost", :port => 6379}

  class Sync

    attr_reader :my_barn, :my_add_queue, :my_change_queue, :my_delete_queue
    attr_reader :add_count, :change_count, :delete_count, :source_count, :cache_count
    attr_reader :redis_settings
    attr_reader :harvester_uuid, :backend, :crop_number

    def initialize(args)

      @queueing = args.fetch(:queueing) { raise "You must provide :queueing" }
      @crop_number = args.fetch(:crop_number) { raise "You must provide :crop_number" }
      @redis_settings = args.fetch(:redis_settings) { DEFAULT_REDIS_SETTINGS }
      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @q = BarnyardHarvester::Queue.new(args)

      #@queueing = args[:queueing]
      #
      #case @queueing
      #  when :rabbitmq
      #    @rabbitmq_settings = args.fetch(:rabbitmq_settings) { raise "You must provide :rabbitmq_settings" }
      #  when :sqs
      #    @sqs_settings = args.fetch(:sqs_settings) { raise "You must provide :sqs_settings" }
      #  else
      #    @queueing = :resque
      #end

      @backend = args.fetch(:backend) { :redis }

      if @backend == :mongodb
        @mongodb_settings = args.fetch(:mongodb_settings) { raise "You must provide :mongodb_settings" }
      end

      require "barnyard_harvester/#{@backend.to_s}_helper" if File.exist? "barnyard_harvester/#{@backend.to_s}_helper"
#      require "barnyard_harvester/#{@queueing.to_s}_queue"
      require "barnyard_harvester/#{@backend.to_s}"

#      YAML::ENGINE.yamler = 'syck'

      @uuid = UUID.new
      @harvester_uuid = @uuid.generate

      @key_store = Hash.new

      # Setup barn and queues
      @my_barn = BarnyardHarvester::Barn.new args
      @my_add_queue = BarnyardHarvester::AddQueue.new args
      @my_change_queue = BarnyardHarvester::ChangeQueue.new args
      @my_delete_queue = BarnyardHarvester::DeleteQueue.new args

      @add_count = @change_count = @delete_count = @source_count = @cache_count = 0

    end

    def delete_run

      deletes = Array.new

      # Iterate Cache Data, detect deletes.
      @my_barn.each do |primary_key, value|

        @cache_count += 1

        next unless @key_store[primary_key].nil?

        # We got delete
        begin
          change_uuid = @uuid.generate
          @my_delete_queue.push @harvester_uuid, change_uuid, @crop_number, primary_key, BarnyardHarvester::DELETE, value
        rescue Exception => e
          @log.fatal "FATAL error pushing delete #{primary_key} to queue. #{e}"
          exit 1
        end

        deletes << primary_key

        @delete_count += 1
      end

      # Remove Deletes from the Cache Data
      deletes.each do |primary_key|
        @my_barn.delete primary_key
      end

    end

    def process primary_key, value

      @source_count += 1

      change_uuid = @uuid.generate

      @key_store[primary_key] = :present # TODO What did this do: if @call_back.nil?

      if @my_barn.has_key? primary_key

        @log.debug "original: #{@my_barn[primary_key]}"

        YAML::ENGINE.yamler = 'syck'

        @log.debug "current : #{Crack::JSON.parse(value.to_json)}"

        if @my_barn[primary_key] != Crack::JSON.parse(value.to_json)
          #We got change!
          begin
            @my_change_queue.push(@harvester_uuid, change_uuid, @crop_number, primary_key, BarnyardHarvester::CHANGE, value, @my_barn[primary_key])
          rescue Exception => e
            @log.fatal "FATAL error pushing change #{primary_key} to queue. #{e}"
            exit 1
          end

          @my_barn[primary_key] = value
          @change_count += 1
        end
      else
        # We got add!
        #begin
          @my_add_queue.push(@harvester_uuid, change_uuid, @crop_number, primary_key, BarnyardHarvester::ADD, value)
        #rescue Exception => e
        #  @log.fatal "FATAL error pushing add #{primary_key} to queue. #{e}"
        #  exit 1
        #end

        @my_barn[primary_key] = value
        @add_count += 1
      end
    end

    def stats
      "(#{@add_count}) adds, (#{@delete_count}) deletes, (#{@change_count}) changes, (#{@source_count}) source records, (#{@cache_count}) cache records"
    end

    #def log_run(harvester_uuid, crop_number, began_at, ended_at, source_count, change_count, add_count, delete_count)
    #
    #  #begin
    #  #rescue Exception => e
    #  #  @log.fatal "#{self.class} Fail in Resque.enqueue of HarvesterLogs. #{e.backtrace}"
    #  #end
    #
    #end

    def run

      @began_at = Time.now

      yield

      # Detect and queue Deletes
      delete_run

      @ended_at = Time.now


      @my_add_queue.log_run(@harvester_uuid, @crop_number, @began_at, @ended_at, @source_count, @change_count, @add_count, @delete_count)

      # Let Farmer know I'm done and to flush the updates
      @my_barn.flush
      @my_add_queue.flush
      @my_change_queue.flush
      @my_delete_queue.flush


    end

  end

end