require "barnyard_harvester"

RABBITMQ_SETTINGS = {
    :host => "localhost"
    #    :port => 6163
}

QUEUE_NAME = "test001"

describe "Test RabbitMQ" do

  before(:each) do

    @q = BarnyardHarvester::GenericQueue.new(queueing: :rabbitmq, rabbitmq_settings: RABBITMQ_SETTINGS)

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