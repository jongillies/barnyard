require "barnyard_ccfeeder"
require "aws-sdk"

describe "this" do

  it "should return subscriptions for the crop" do

    crop_number = 10

    #url = "https://cachecow.c.qaapollogrp.edu"
    url = "http://localhost:3000"

    cc = BarnyardCcfeeder::CacheCow.new :url => url

    subs = cc.has_subscribers(crop_number)

    subs.each do |subscription|

      puts "Subscription ID: #{subscription["id"]}"
      puts "Subscriber   ID: #{subscription["subscriber"]["id"]}"
      puts "Crop Number    : #{subscription["crop"]["crop_number"]}"

    end

  end

  #it "should iterate the subscriptions" do
  #
  #  crop_number = 13
  #
  #  cc = BarnyardCcfeeder::CacheCow.new :url => "http://localhost:3000"
  #
  #  cc.subscriptions.each do |subscription_id, subscription|
  #
  #    unless subscription["active"] == true
  #      puts("#{self.name} Subscription #{subscription_id} is not active.")
  #      next
  #    end
  #
  #    if cc.crops[subscription["crop_id"]]["crop_number"] == crop_number
  #
  #      puts "subscribed #{subscription["subscriber_id"]} crop #{crop_number}"
  #
  #    else
  #      puts("# #{cc.subscribers[subscription["subscriber_id"]]["name"]} is subscribed to #{cc.crops_by_crop_number[crop_number]["name"]}")
  #    end
  #  end
  #
  #end

end