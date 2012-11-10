# BarnyardAws

This gem provides access to the following Amazon AWS objects:

* BarnyardAws::AwsElbs
* BarnyardAws::AwsSecurityGroups
* BarnyardAws::AwsInstances
* BarnyardAws::AwsSnapshots
* BarnyardAws::AwsVolumes
* BarnyardAws::AwsSubnets
* BarnyardAws::AwsIamUsers
* BarnyardAws::AwsIamGroupPolicies

This gem requires the "barnyard_havester" gem.

## Installation

Add this line to your application's Gemfile:

    gem 'barnyard_aws'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install barnyard_aws

## Usage

Using this gem is trival.  It will iterate the AWS objects and send them to the BarnyardHarvester.

WARNING!  Do not use crop number 1-9 in production, they are reserved for system testing.

      require "barnyard_aws"

      my_logger = Logger.new(STDOUT)
      my_logger.level = Logger::INFO

      redis_settings = {
          :host => "localhost",
          :port => 6379,
      }

      BarnyardAws::AwsElbs.new(aws_access_key_id: AWS_ACCESS_KEY_ID,
                               aws_secret_access_key: AWS_SECRET_ACCESS_KEY,
                               region: "us-west-1",
                               account_id: "dev",
                               crop_number: 1,
                               logger: my_logger,
                               redis_settings: redis_settings,
                               debug: true)

A note about primary keys using BarnyardAws.  The "account_id" is added befor the AWS ObjectID separated by a dash.  It is imparative that you use unique "account_ids" across different aws accounts.  The account_id can be any string and is not tied to the AWS API.  It is merly for reference.

## Testing

RSPEC is used to test this gem.  Note that you should run each spec test individually.  For some reason they confilict if run together.  You will need Redis installed on the localhost:6379 or adjust the test accordingly.

This tests all of the AWS supported objects:

    rspec spec/aws_spec.rb

Note that this test requires the AWS credentails be set in the environment:

    AWS_ACCESS_KEY_ID="****"
    AWS_SECRET_ACCESS_KEY="****"

This test will use the crop_number 1 and will iterate all supported AWS objects.

## Questions or Problems?

supercoder@gmail.com

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request