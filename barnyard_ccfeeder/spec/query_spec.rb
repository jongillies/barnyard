require "barnyard_ccfeeder"
require "aws-sdk"

describe "this" do

  it "should load properly" do

    crop_number = 13

    cc = BarnyardCcfeeder::CacheCow.new :url => "http://localhost:3000"

    cc.subscriptions.each do |subscription_id, subscription|

      unless subscription["active"] == true
        puts("#{self.name} Subscription #{subscription_id} is not active.")
        next
      end

      if cc.crops[subscription["crop_id"]]["crop_number"] == crop_number

        puts "subscribed #{subscription["subscriber_id"]} crop #{crop_number}"

      else
        puts("# #{cc.subscribers[subscription["subscriber_id"]]["name"]} is subscribed to #{cc.crops_by_crop_number[crop_number]["name"]}")
      end
    end

  end

end