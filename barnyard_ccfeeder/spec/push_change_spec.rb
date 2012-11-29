require "barnyard_ccfeeder"
require "aws-sdk"
require "uuid"
require "spec_helper"

describe "this" do

  it "should load properly" do

    cc = BarnyardCcfeeder::CacheCow.new :url => "http://localhost:3000"

    queued_at = Time.now
    crop_number = 1
    primary_key = "ABC"
    transaction_type = "add"
    value = "{}"
    old_value = "{}"

    cc.push_change(queued_at,
                   $harvester_uuid,
                   $change_uuid,
                   crop_number,
                   primary_key,
                   transaction_type,
                   value,
                   old_value)

    end
end