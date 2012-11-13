require "mongo"
require "logger"

module BarnyardHarvester
  class MongoDbHelper

    def self.connect(args)

      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @log.debug "Connection parameters #{args[:host]} db: #{args[:db]} collection: #{args[:collection]}" if @debug

      # Connect to Mongo
      if args.has_key? :host
        if args[:host].is_a? Array
          @log.debug "Connecting to replica set #{args[:host]}"
          @mongo = Mongo::ReplSetConnection.new(args[:host]).db(args[:db])
        else
          @log.debug "Connecting to single host #{args[:host]}"
          @mongo = Mongo::Connection.new(args[:host].split(":")[0], args[:host].split(":")[1]).db(args[:db])
        end
      else
        @log.info "Connecting to localhost #{args[:host]}"
        @mongo = Mongo::Connection.new.db(args[:db])
      end

      #db = @mongo.db((mongo_args[:db])
      #auth = db.authenticate

      unless args[:user].to_s == ''
        @log.debug "Authenticating as #{args[:user]}"
        @mongo.authenticate(args[:user], args[:password])
      end

      @mongo
    end
  end
end

if __FILE__ == $0

  mongo_replica_set = Array.new

  mongo_replica_set << "ip-172-19-31-44.c.qaapollogrp.edu:27017"
  mongo_replica_set << "ip-172-19-30-49.c.qaapollogrp.edu:27017"
  mongo_replica_set << "ip-172-19-31-202.c.qaapollogrp.edu:27017"

  mongo_args = Hash.new
#  mongo_args[:host] = "localhost:27017"
  mongo_args[:host] = mongo_replica_set
  mongo_args[:db] = "aws"
  mongo_args[:collection] = "test_collection"
  mongo_args[:user] = "honeybadger"
  mongo_args[:password] = "0joQuk35vJM05Hj"

  mongo_args[:debug] = true

  my_log = Logger.new(STDOUT)

  mongo_args[:logger] = my_log

  s = ApolMongo::MongoHelper.connect mongo_args

  c = s.collection(mongo_args[:collection])


  c.find.each do |row|
    puts row
  end

end
