require "barnyard_harvester"

RABBITMQ_SETTINGS = {
    :host => "localhost"
    #    :port => 6163
}

describe BarnyardHarvester do

  it "no parameters should raise error" do
    lambda{BarnyardHarvester::Sync.new}.should raise_error
  end

  it "passing only :crop_number => 1 should return BarnyardHarvester::Sync object" do
    BarnyardHarvester::Sync.new(rabbitmq_settings: RABBITMQ_SETTINGS, queueing: :rabbitmq, crop_number: 1).class.should eq(BarnyardHarvester::Sync)
  end

  it "default backend should be :redis" do
    BarnyardHarvester::Sync.new(rabbitmq_settings: RABBITMQ_SETTINGS, queueing: :rabbitmq, crop_number: 1).backend.should eq(:redis)
  end

  it "passing backend :hash should be :hash" do
    BarnyardHarvester::Sync.new(rabbitmq_settings: RABBITMQ_SETTINGS, queueing: :rabbitmq, crop_number: 1, backend: :hash).backend.should eq(:hash)
  end

  it "passing bogus backend should raise an error" do
    lambda{BarnyardHarvester::Sync.new(rabbitmq_settings: RABBITMQ_SETTINGS, queueing: :rabbitmq, crop_number: 1, backend: :foobar)}.should raise_error
  end

  it "crop_number should be 1001" do
    BarnyardHarvester::Sync.new(rabbitmq_settings: RABBITMQ_SETTINGS, queueing: :rabbitmq, crop_number: 1001).crop_number.should eq(1001)
  end

  it "all counters should be zero" do
    BarnyardHarvester::Sync.new(rabbitmq_settings: RABBITMQ_SETTINGS, queueing: :rabbitmq, crop_number: 1).change_count.should eq(0)
    BarnyardHarvester::Sync.new(rabbitmq_settings: RABBITMQ_SETTINGS, queueing: :rabbitmq, crop_number: 1).add_count.should eq(0)
    BarnyardHarvester::Sync.new(rabbitmq_settings: RABBITMQ_SETTINGS, queueing: :rabbitmq, crop_number: 1).delete_count.should eq(0)
    BarnyardHarvester::Sync.new(rabbitmq_settings: RABBITMQ_SETTINGS, queueing: :rabbitmq, crop_number: 1).source_count.should eq(0)
    BarnyardHarvester::Sync.new(rabbitmq_settings: RABBITMQ_SETTINGS, queueing: :rabbitmq, crop_number: 1).cache_count.should eq(0)
  end

end