require "rspec"
require "barnyard_market"

#DYNAMODB_SETTINGS = {
#    :dynamo_db_endpoint => "dynamodb.us-west-1.amazonaws.com",
#    :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
#    :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"]
#}
#
#SQS_SETTINGS = {
#    :sqs_endpoint => "sqs.us-west-1.amazonaws.com",
#    :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
#    :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"]
#}

["BACKEND_AWS_SECRET_ACCESS_KEY",
 "BACKEND_AWS_ACCESS_KEY_ID",
 "BACKEND_AWS_REGION",
 "AWS_SECRET_ACCESS_KEY",
 "AWS_ACCESS_KEY_ID"].each do |env_var|
  eval("#{env_var}=ENV[\"#{env_var}\"]")
  if eval("#{env_var}.nil?")
    raise "You must specify #{env_var} in the environment."
  end
end

DYNAMODB_SETTINGS = {
    :dynamo_db_endpoint => "dynamodb.#{BACKEND_AWS_REGION}.amazonaws.com",
    :access_key_id => BACKEND_AWS_ACCESS_KEY_ID,
    :secret_access_key => BACKEND_AWS_SECRET_ACCESS_KEY
}

SQS_SETTINGS = {
    :sqs_endpoint => "sqs.#{BACKEND_AWS_REGION}.amazonaws.com",
    :access_key_id => BACKEND_AWS_ACCESS_KEY_ID,
    :secret_access_key => BACKEND_AWS_SECRET_ACCESS_KEY
}

CACHECOW_SETTINGS = {
    #:url => "http://localhost:3000"
    :url => "https://cachecow.c.qaapollogrp.edu"
}

describe "i should" do

  it "should work" do

    my_logger = Logger.new(STDOUT)
    my_logger.level = Logger::DEBUG

    h = BarnyardMarket::ProcessSubscriptions.new(:queueing => :sqs,
                                                 :sqs_settings => SQS_SETTINGS,
                                                 :backend => :dynamodb,
                                                 :debug => true,
                                                 :dynamodb_settings => DYNAMODB_SETTINGS,
                                                 :cachecow_settings => CACHECOW_SETTINGS,
                                                 :logger => my_logger)


    #To change this template use File | Settings | File Templates.
    true.should == true
  end
end