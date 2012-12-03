require "barnyard_harvester"

SQS_SETTINGS = {
    :sqs_endpoint => "sqs.us-west-1.amazonaws.com",
    :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
    :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"]
}

QUEUE_NAME = "test001"

describe "Test SQS" do

  before(:each) do

    @q = BarnyardHarvester::GenericQueue.new(queueing: :sqs, sqs_settings: SQS_SETTINGS)

  end

  it "Push 10 items on the queue" do

    @q.empty(QUEUE_NAME)

    10.times do |i|
      @q.push(QUEUE_NAME, "My Message #{i}")
    end

  end

  it "Pop 10 items" do

  10.times do |i|
      msg = @q.pop(QUEUE_NAME)
      puts msg
    end

  end


end