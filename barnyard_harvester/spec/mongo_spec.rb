require "barnyard_harvester"
require "yaml"
require "mongo"
require "redis"
require "logger"
require "json"

CROP_NUMBER = 1

REDIS_SETTINGS = {
    :host => "localhost",
    :port => 6379,
    :db => CROP_NUMBER
}

MONGODB_SETTINGS = {
    :host_list => "localhost:27017",
    :collection => "test_collection",
    :db => "test_db"
}

describe BarnyardHarvester do

  def load_and_process_file(file, backend)

    data = YAML::load_file file

    my_logger = Logger.new(STDOUT)
    my_logger.level = Logger::INFO

    h = BarnyardHarvester::Sync.new(:backend => backend, :debug => false, :mongo_settings => MONGODB_SETTINGS, :crop_number => CROP_NUMBER, :redis_settings => REDIS_SETTINGS, :logger => my_logger)

    h.run do
      data.each do |primary_key, value|
        h.process primary_key, value
      end
    end

    h
  end

  def flush

    require "barnyard_harvester/mongodb_helper"

    mongo = BarnyardHarvester::MongoDbHelper.connect MONGODB_SETTINGS
    collection_name = MONGODB_SETTINGS[:collection]
    collection = mongo.collection(collection_name)

    collection.find.each do |row|
      collection.remove("_id" => row["_id"])
    end

  end

  before(:each) do

    flush

    @crop_number = 1

    file = "spec/fixtures/data-init.yml"

    data = YAML::load_file file

    h = load_and_process_file(file, :mongodb)

    h.add_count.should eq(data.count)
    h.delete_count.should eq(0)
    h.change_count.should eq(0)
    h.source_count.should eq(data.count)
    h.cache_count.should eq(data.count)

  end

  it "test initial load of records" do

    data = YAML::load_file "spec/fixtures/data-init.yml"

    mongo = BarnyardHarvester::MongoDbHelper.connect MONGODB_SETTINGS
    collection = mongo.collection(MONGODB_SETTINGS[:collection])

    data.each do |primary_key, value|

      doc = collection.find("_id" => primary_key).to_a[0]

      doc.delete("_id")

      value.should eq(doc)
    end

  end

  it "test add one record" do

    file = "spec/fixtures/data-add.yml"
    data = YAML::load_file file

    h = load_and_process_file(file, :mongodb)

    h.add_count.should eq(1)
    h.delete_count.should eq(0)
    h.change_count.should eq(0)
    h.source_count.should eq(data.count)
    h.cache_count.should eq(data.count)

  end

  it "test change one record" do

    file = "spec/fixtures/data-change.yml"

    data = YAML::load_file file

    h = load_and_process_file(file, :mongodb)

    h.add_count.should eq(0)
    h.delete_count.should eq(0)
    h.change_count.should eq(1)
    h.source_count.should eq(data.count)
    h.cache_count.should eq(data.count)

  end

  it "test delete one record" do

    file = "spec/fixtures/data-delete.yml"

    data = YAML::load_file file

    h = load_and_process_file(file, :mongodb)


    h.add_count.should eq(0)
    h.delete_count.should eq(1)
    h.change_count.should eq(0)
    h.source_count.should eq(data.count)
    h.cache_count.should eq(data.count + 1)

  end

  it "test delete all records and add one" do

    init_file = "spec/fixtures/data-init.yml"
    init_data = YAML::load_file init_file

    file = "spec/fixtures/data-delete-all-records-add-one.yml"
    #data = YAML::load_file file

    h = load_and_process_file(file, :mongodb)

    h.add_count.should eq(1)
    h.delete_count.should eq(5)
    h.change_count.should eq(0)
    h.source_count.should eq(1)
    h.cache_count.should eq(init_data.count + 1)

  end


  after(:each) do
  end


end