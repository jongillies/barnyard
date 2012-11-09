require "aws_auditor"
require "logger"

describe AwsAuditor do

  AWS_SECRET_ACCESS_KEY=ENV["AWS_SECRET_ACCESS_KEY"]
  AWS_ACCESS_KEY_ID=ENV["AWS_ACCESS_KEY_ID"]

  it "all should work" do

    my_logger = Logger.new(STDOUT)
    my_logger.level = Logger::INFO

    redis_settings = {
        :host => "localhost",
        :port => 6379,
    }

    [AwsAuditor::AwsElbs, AwsAuditor::AwsSecurityGroups,
     AwsAuditor::AwsInstances, AwsAuditor::AwsSnapshots,
     AwsAuditor::AwsVolumes, AwsAuditor::AwsSubnets,
     AwsAuditor::AwsIamUsers, AwsAuditor::AwsIamGroupPolicies].each do |o|

      o.new(aws_access_key_id: AWS_ACCESS_KEY_ID,
            aws_secret_access_key: AWS_SECRET_ACCESS_KEY,
            region: "us-west-1",
            account_id: "dev",
            crop_number: 1,
            logger: my_logger,
            redis_settings: redis_settings,
            debug: true)

    end
  end

end