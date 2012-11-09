# Harvester

The Harvester gem provides a simple interface where you can iterate your data source and send records to the sync engine.  The default backend storage is Redis.  Since the workers will use Resque which requires Redis, this make sense to use Redis to cache the data.  However, any backend cache can be implemented.

Your data sources are called "crops".  You must assign a unique integer 1..100 to each crop.  This is the integer that is used to create the Redis collection.  By default Redis only allows a maximum of 16 databases, so this must be changed if you go above 16.

The sync engine keeps a copy of your data source in a Redis databased indexed on the data source's primary key.  When you sync your data, the engine uses this "cached" copy of the data to determine adds, deletes and changes.  None of the data is inspected and the sync engine does not care what is in the data as long as it can be marshaled into a JSON string.  The sync engine automatically does the conversion to and from JSON, so all you pass in is an object that responds to .to_json.

## Installation

    gem install harvester

## Getting Started

This example assumes that you have Redis running on your local box localhost:6379.  If you do not have Redis installed you can add :backend => :hash to the constructor.

    require "harvester"

    # Get a connection to your data source
    # (For this example we will use a YAML file)

    @data = YAML::load_file("test.yml")

    h = Harvester::Sync.new(:debug => false, :crop_number => 1,
                            #:backend => :hash
    )

    h.run do

      # Iterate your data here and call #process with the primary key and the value
      @data.each do |primary_key, value|
        my_log.info "PK: #{primary_key}"
        h.process primary_key, value
      end

    end

    puts h.stats

Sample output:

    (0) adds, (0) deletes, (0) changes, (5) source records, (5) cache records


## Questions or Problems?

