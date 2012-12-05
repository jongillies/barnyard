require "barnyard_dns"
require "logger"

describe BarnyardDns do

  it "all should work" do

    my_logger = Logger.new(STDOUT)
    my_logger.level = Logger::INFO

    REDIS_SETTINGS = {
        :host => "localhost",
        :port => 6379,
    }

    RABBITMQ_SETTINGS = {
        :host => "localhost"
        #    :port => 6163
    }

    BarnyardDns::DnsObject.new(
        zone: "example.com",
        crop_number: 2,
        logger: my_logger,
        redis_settings: REDIS_SETTINGS,
        rabbitmq_settings: RABBITMQ_SETTINGS,
        backend: :redis,
        queueing: :rabbitmq,
        debug: true)

  end

end
