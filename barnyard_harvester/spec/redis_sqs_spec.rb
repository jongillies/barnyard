require "barnyard_harvester"
require "yaml"
require "redis"
require "logger"
require "json"

CROP_NUMBER = 1

REDIS_SETTINGS = {
    :host => "localhost",
    :port => 6379,
    :db => CROP_NUMBER
}


SQS_SETTINGS = {
    :sqs_endpoint => "sqs.us-west-1.amazonaws.com",
    :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
    :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"]
}

describe BarnyardHarvester do

  def load_and_process_file(file, backend)

    data = YAML::load_file file

    my_logger = Logger.new(STDOUT)
    my_logger.level = Logger::DEBUG

    h = BarnyardHarvester::Sync.new(:queueing => :sqs,
                                    :sqs_settings => SQS_SETTINGS,
                                    :backend => backend,
                                    :debug => true,
                                    :crop_number => CROP_NUMBER,
                                    :redis_settings => REDIS_SETTINGS,
                                    :logger => my_logger)

    h.run do
      data.each do |primary_key, value|
        h.process primary_key, value
      end
    end

    h
  end

  def flush

    r = Redis.new(REDIS_SETTINGS)

    r.keys.each do |k|
      r.del k
      #puts "deleted #{k}"
    end

  end

  before(:each) do

    flush

    @crop_number = 1

    file = "spec/fixtures/data-init.yml"

    data = YAML::load_file file

    h = load_and_process_file(file, :redis)

    h.add_count.should eq(data.count)
    h.delete_count.should eq(0)
    h.change_count.should eq(0)
    h.source_count.should eq(data.count)
    h.cache_count.should eq(data.count)

  end

  it "test initial load of records" do

    data = YAML::load_file "spec/fixtures/data-init.yml"

    redis = Redis.new(REDIS_SETTINGS)

    data.each do |primary_key, value|
      value.to_json.should eq(redis.get(primary_key))
    end

  end

  it "test add one record" do

    file = "spec/fixtures/data-add.yml"
    data = YAML::load_file file

    h = load_and_process_file(file, :redis)

    h.add_count.should eq(1)
    h.delete_count.should eq(0)
    h.change_count.should eq(0)
    h.source_count.should eq(data.count)
    h.cache_count.should eq(data.count)

#    h.log_run("#{file}-#{Random.rand(100)}", @crop_number, Time.now, Time.now, h.source_count, h.change_count, h.add_count, h.delete_count)

  end

  it "test change one record" do

    file = "spec/fixtures/data-change.yml"

    data = YAML::load_file file

    h = load_and_process_file(file, :redis)

    h.add_count.should eq(0)
    h.delete_count.should eq(0)
    h.change_count.should eq(1)
    h.source_count.should eq(data.count)
    h.cache_count.should eq(data.count)

#    h.my_barn.log_run("#{file}-#{Random.rand(100)}", @crop_number, Time.now, Time.now, h.source_count, h.change_count, h.add_count, h.delete_count)

  end

  it "test delete one record" do

    file = "spec/fixtures/data-delete.yml"

    data = YAML::load_file file

    h = load_and_process_file(file, :redis)


    h.add_count.should eq(0)
    h.delete_count.should eq(1)
    h.change_count.should eq(0)
    h.source_count.should eq(data.count)
    h.cache_count.should eq(data.count + 1)

#    h.my_barn.log_run("#{file}-#{Random.rand(100)}", @crop_number, Time.now, Time.now, h.source_count, h.change_count, h.add_count, h.delete_count)

  end

  it "test delete all records and add one" do

    init_file = "spec/fixtures/data-init.yml"
    init_data = YAML::load_file init_file

    file = "spec/fixtures/data-delete-all-records-add-one.yml"
    #data = YAML::load_file file

    h = load_and_process_file(file, :redis)

    h.add_count.should eq(1)
    h.delete_count.should eq(5)
    h.change_count.should eq(0)
    h.source_count.should eq(1)
    h.cache_count.should eq(init_data.count + 1)

#    h.my_barn.log_run("#{file}-#{Random.rand(100)}", @crop_number, Time.now, Time.now, h.source_count, h.change_count, h.add_count, h.delete_count)

  end


  after(:each) do
  end


end