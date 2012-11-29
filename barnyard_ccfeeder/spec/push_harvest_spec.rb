require "barnyard_ccfeeder"
require "aws-sdk"
require "uuid"
require "spec_helper"

describe "this" do

  it "should load properly" do

    cc = BarnyardCcfeeder::CacheCow.new :url => "http://localhost:3000"

    crop_number = 1
    began_at = Time.now
    ended_at = Time.now
    number_of_changes = 0
    number_of_adds = 1
    number_of_deletes = 0
    total_records = 1

    cc.push_harvester_stats($harvester_uuid,
                            crop_number,
                            began_at,
                            ended_at,
                            total_records,
                            number_of_changes,
                            number_of_adds,
                            number_of_deletes)

  end
end