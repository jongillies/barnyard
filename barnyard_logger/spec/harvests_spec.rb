require "rspec"
require "barnyard_logger"

DYNAMODB_SETTINGS = {
    :dynamo_db_endpoint => "dynamodb.us-west-1.amazonaws.com",
    :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
    :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"]
}

SQS_SETTINGS = {
    :sqs_endpoint => "sqs.us-west-1.amazonaws.com",
    :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
    :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"]
}

CACHECOW_SETTINGS = {
    :url => "http://localhost:3000"
}

describe "i should" do

  it "should work" do

    my_logger = Logger.new(STDOUT)
    my_logger.level = Logger::DEBUG

    l = BarnyardLogger::Logs.new(:queueing => :sqs,
                                 :sqs_settings => SQS_SETTINGS,
                                 :backend => :dynamodb,
                                 :debug => true,
                                 :dynamodb_settings => DYNAMODB_SETTINGS,
                                 :cachecow_settings => CACHECOW_SETTINGS,
                                 :logger => my_logger)

    l.process_harvests


  end
end
