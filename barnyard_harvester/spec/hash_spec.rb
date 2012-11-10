require "barnyard_harvester"
require "yaml"
require "redis"
require "logger"
require "json"


# TODO.. Move the flush to the backend object, not here!!!!!!!!!

describe BarnyardHarvester do


  def load_and_process_file(file, backend)

    data = YAML::load_file file

    redis_settings = {
        :host => "localhost",
        :port => 6379,
    }

    my_logger = Logger.new(STDOUT)
    my_logger.level = Logger::INFO

    h = BarnyardHarvester::Sync.new(:backend => backend, :debug => false, :crop_number => 1, :hash_settings => redis_settings, :logger => my_logger)

    h.run do
      data.each do |primary_key, value|
        h.process primary_key, value
      end
    end

    h
  end

  def flush(crop_number)

    File.delete("#{crop_number}-BarnyardHarvester::Barn.yml") if File.exist? "#{crop_number}-BarnyardHarvester::Barn.yml"

  end

  before(:each) do


    @crop_number = 1

    flush @crop_number

    file = "spec/fixtures/data-init.yml"

    data = YAML::load_file file

    h = load_and_process_file(file, :hash)

    h.add_count.should eq(data.count)
    h.delete_count.should eq(0)
    h.change_count.should eq(0)
    h.source_count.should eq(data.count)
    h.cache_count.should eq(data.count)

  end

  #it "test initial load of records" do
  #
  #  data = YAML::load_file "spec/fixtures/data-init.yml"
  #
  #  redis = Redis.new(:db => 1)
  #
  #  data.each do |primary_key, value|
  #    value.to_json.should eq(redis.get(primary_key))
  #  end
  #
  #end

  it "test add one record" do

    file = "spec/fixtures/data-add.yml"
    data = YAML::load_file file

    h = load_and_process_file(file, :hash)

    h.add_count.should eq(1)
    h.delete_count.should eq(0)
    h.change_count.should eq(0)
    h.source_count.should eq(data.count)
    h.cache_count.should eq(data.count)

  end

  it "test change one record" do

    file = "spec/fixtures/data-change.yml"

    data = YAML::load_file file

    h = load_and_process_file(file, :hash)

    h.add_count.should eq(0)
    h.delete_count.should eq(0)
    h.change_count.should eq(1)
    h.source_count.should eq(data.count)
    h.cache_count.should eq(data.count)

  end

  it "test delete one record" do

    file = "spec/fixtures/data-delete.yml"

    data = YAML::load_file file

    h = load_and_process_file(file, :hash)


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

    h = load_and_process_file(file, :hash)

    h.add_count.should eq(1)
    h.delete_count.should eq(5)
    h.change_count.should eq(0)
    h.source_count.should eq(1)
    h.cache_count.should eq(init_data.count + 1)

  end


  after(:each) do
  end


end