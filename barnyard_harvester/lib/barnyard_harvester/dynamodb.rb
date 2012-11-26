require "crack"
require "json"
require "aws-sdk"

module BarnyardHarvester

  DEFAULT_DYNAMODB_SETTINGS = {
      :dynamo_db_endpoint => "dynamodb.us-west-1.amazonaws.com",
      :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
      :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"]
  }

  class Barn

    def initialize(args)

      @crop_number = args.fetch(:crop_number) { raise "You must provide :crop_number" }
      @dynamodb_settings = args.fetch(:dynamodb_settings) { DEFAULT_DYNAMODB_SETTINGS }
      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @db = AWS::DynamoDB.new(@dynamodb_settings)

      table_name = "barnyard_crop_id-#{@crop_number}"

      begin
        @table = @db.tables.create(table_name, 10, 5)
        sleep 1 while @table.status == :creating
        @table.hash_key = [:id, :string]
        puts @table.status
        puts "Creating table #{table_name}"
      rescue AWS::DynamoDB::Errors::ResourceInUseException
        puts "#{table_name} table exists"
        @table = @db.tables[table_name]
        @table.hash_key = [:id, :string]
      end

    end

    def delete(primary_key)
      check_key primary_key

      item = @table.items.find('id' => primary_key).first # Save the value
      value = item.attributes['value']
      item.delete # Delete the key
      Crack::JSON.parse(value) # Return the object
    end

    def []= primary_key, object
      check_key primary_key
      check_object object
      @table.items.create('id' => primary_key, 'value' => object.to_json)
    end

    def [] primary_key
      check_key primary_key

      Crack::JSON.parse(@table.items.find('id' => primary_key).first.attributes['value'])
    end

    def has_key?(primary_key)
      check_key primary_key

      begin
        @table.items.find('id' => primary_key).first == nil
      rescue
        false
      end

    end

    def each

      @table.items.each do |i|
        yield i.attributes['id'], i.attributes['value']
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