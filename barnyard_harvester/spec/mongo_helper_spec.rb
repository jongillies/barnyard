require "rspec"
require "./lib/barnyard_harvester/mongodb_helper"

describe BarnyardHarvester::MongoDbHelper do

  it "should connect to a replica set" do

    mongo_replica_set = Array.new

    mongo_replica_set << "ip-172-19-31-44.c.qaapollogrp.edu:27017"
    mongo_replica_set << "ip-172-19-30-49.c.qaapollogrp.edu:27017"
    mongo_replica_set << "ip-172-19-31-202.c.qaapollogrp.edu:27017"
    mongo_args = Hash.new


    mongo_args[:host] = mongo_replica_set
    mongo_args[:db] = "aws"
    mongo_args[:collection] = "test_collection"
    mongo_args[:user] = "honeybadger"
    mongo_args[:password] = "0joQuk35vJM05Hj"

    mongo_args[:debug] = true

    my_log = Logger.new(STDOUT)

    mongo_args[:logger] = my_log

    s = BarnyardHarvester::MongoDbHelper.connect mongo_args

    c = s.collection(mongo_args[:collection])

    c.find.each do |row|
      puts row
    end

  end

  it "should connect to one server" do

    mongo_args = Hash.new
    mongo_args[:host] = "localhost:27017"
    mongo_args[:db] = "aws"
    mongo_args[:collection] = "test_collection"

    mongo_args[:debug] = true

    my_log = Logger.new(STDOUT)

    mongo_args[:logger] = my_log

    s = BarnyardHarvester::MongoDbHelper.connect mongo_args

    c = s.collection(mongo_args[:collection])

    c.find.each do |row|
      puts row
    end

  end

end