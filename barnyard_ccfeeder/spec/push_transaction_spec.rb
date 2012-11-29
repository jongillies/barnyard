require "barnyard_ccfeeder"
require "aws-sdk"
require "uuid"
require "spec_helper"

describe "this" do

  it "should load properly" do

    cc = BarnyardCcfeeder::CacheCow.new :url => "http://localhost:3000"

    queued_at = Time.now

    subscription_id = 1

    cc.push_transaction(subscription_id, queued_at, $change_uuid, $transaction_uuid)

  end
end