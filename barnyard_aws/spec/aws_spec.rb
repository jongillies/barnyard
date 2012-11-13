require "barnyard_aws"
require "logger"

describe BarnyardAws do

  AWS_SECRET_ACCESS_KEY=ENV["AWS_SECRET_ACCESS_KEY"]
  AWS_ACCESS_KEY_ID=ENV["AWS_ACCESS_KEY_ID"]

  it "all should work" do

    my_logger = Logger.new(STDOUT)
    my_logger.level = Logger::INFO

    REDIS_SETTINGS = {
        :host => "localhost",
        :port => 6379
    }

    mongodb_settings = {
        :host_list => "localhost:27017",
        :db => "test_db",
    }

    [BarnyardAws::AwsElbs,
     BarnyardAws::AwsSecurityGroups,
     BarnyardAws::AwsInstances, BarnyardAws::AwsSnapshots,
     BarnyardAws::AwsVolumes, BarnyardAws::AwsSubnets,
     BarnyardAws::AwsIamUsers, BarnyardAws::AwsIamGroupPolicies
    ].each do |o|

      mongodb_settings[:collection] = o.to_s

      o.new(aws_access_key_id: AWS_ACCESS_KEY_ID,
            aws_secret_access_key: AWS_SECRET_ACCESS_KEY,
            region: "us-west-1",
            account_id: "dev",
            crop_number: 1,
            logger: my_logger,
            redis_settings: REDIS_SETTINGS,
            mongodb_settings: mongodb_settings,
            backend: :mongodb,
            debug: true)

    end
  end

end
