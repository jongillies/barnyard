require "harvester"

describe Harvester do

  it "no parameters should raise error" do
    lambda{Harvester::Sync.new}.should raise_error
  end

  it "passing only :crop_number => 1 should return Harvester::Sync object" do
    Harvester::Sync.new(crop_number: 1).class.should eq(Harvester::Sync)
  end

  it "default backend should be :redis" do
    Harvester::Sync.new(crop_number: 1).backend.should eq(:redis)
  end

  it "passing backend :hash should be :hash" do
    Harvester::Sync.new(crop_number: 1, backend: :hash).backend.should eq(:hash)
  end

  it "passing bogus backend should raise an error" do
    lambda{Harvester::Sync.new(crop_number: 1, backend: :foobar)}.should raise_error
  end

  it "crop_number should be 1001" do
    Harvester::Sync.new(crop_number: 1001).crop_number.should eq(1001)
  end

  it "all counters should be zero" do
    Harvester::Sync.new(crop_number: 1).change_count.should eq(0)
    Harvester::Sync.new(crop_number: 1).add_count.should eq(0)
    Harvester::Sync.new(crop_number: 1).delete_count.should eq(0)
    Harvester::Sync.new(crop_number: 1).source_count.should eq(0)
    Harvester::Sync.new(crop_number: 1).cache_count.should eq(0)
  end

end