require "fog"
require "harvester"
require "json"

require "aws_auditor/version"

module AwsAuditor

  class AwsObject

    attr_reader :synchronizer, :began_at, :ended_at

    def make_primary_key(account, key)
      "#{account}-#{key}"
    end

    def initialize(args={})

      @began_at = Time.now

      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @aws_access_key_id = args.fetch(:aws_access_key_id) { raise "You must provide :aws_access_key_id" }
      @aws_secret_access_key = args.fetch(:aws_secret_access_key) { raise "You must provide :aws_secret_access_key" }
      @region = args.fetch(:region) { raise "You must provide :region" }
      @account_id = args.fetch(:account_id) { raise "You must provide :account_id" }

#      @log.debug JSON.pretty_generate(args)
      puts JSON.pretty_generate(args)
      @log.debug "region=#{@region}"

      @synchronizer = Harvester::Sync.new(args)

      @synchronizer.run do

        case self.class.to_s
          when "AwsAuditor::AwsElbs"
            compute = Fog::AWS::ELB.new({
                                            :aws_access_key_id => @aws_access_key_id,
                                            :aws_secret_access_key => @aws_secret_access_key,
                                            :region => @region
                                        })
          when "AwsAuditor::AwsIamUsers",
              "AwsAuditor::AwsIamGroupPolicies"
            compute = Fog::AWS::IAM.new({
                                            :aws_access_key_id => @aws_access_key_id,
                                            :aws_secret_access_key => @aws_secret_access_key,
                                            #:region => @region
                                        })
          else
            compute = Fog::Compute.new({
                                           :provider => 'AWS',
                                           :aws_access_key_id => @aws_access_key_id,
                                           :aws_secret_access_key => @aws_secret_access_key,
                                           :region => @region
                                       })
        end

        case self.class.to_s
          when "AwsAuditor::AwsSecurityGroups"
            compute.security_groups.each do |security_group|
              unless security_group.group_id.nil?
                obj = Crack::JSON.parse security_group.to_json
                obj["account_id"] = @account_id

                primary_key = make_primary_key(@account_id, security_group.group_id)
                @log.info "#{primary_key}"

                @synchronizer.process primary_key, obj

              end
            end

          when "AwsAuditor::AwsInstances"
            compute.servers.each do |s|
              unless s.id.nil?
                obj = Crack::JSON.parse s.to_json
                obj["account_id"] = @account_id

                primary_key = make_primary_key(@account_id, s.id)
                @log.info "#{primary_key}"

                @synchronizer.process primary_key, obj

              end
            end

          when "AwsAuditor::AwsSnapshots"
            compute.snapshots.each do |snapshot|
              unless snapshot.id.nil?
                obj = Crack::JSON.parse snapshot.to_json
                obj["account_id"] = @account_id

                primary_key = make_primary_key(@account_id, snapshot.id)
                @log.info "#{primary_key}"

                @synchronizer.process primary_key, obj

              end
            end

          when "AwsAuditor::AwsVolumes"
            compute.volumes.each do |s|
              unless s.id.nil?
                obj = Crack::JSON.parse s.to_json
                obj["account_id"] = @account_id

                primary_key = make_primary_key(@account_id, s.id)
                @log.info "#{primary_key}"

                @synchronizer.process primary_key, obj

              end
            end

          when "AwsAuditor::AwsSubnets"
            compute.subnets.each do |s|
              unless s.subnet_id.nil?
                obj = Crack::JSON.parse s.to_json
                obj["account_id"] = @account_id

                primary_key = make_primary_key(@account_id, s.subnet_id)
                @log.info "#{primary_key}"

                @synchronizer.process primary_key, obj

              end
            end

          when "AwsAuditor::AwsElbs"
            compute.load_balancers.each do |elb|
              unless elb.dns_name.nil?
                obj = Crack::JSON.parse elb.to_json
                obj["account_id"] = @account_id

                primary_key = make_primary_key(@account_id, elb.dns_name)
                @log.info "#{primary_key}"

                @synchronizer.process primary_key, obj

              end
            end

          when "AwsAuditor::AwsIamUsers"
            compute.list_users.body["Users"].each do |user|
              unless user['UserId'].nil?
                access_keys = compute.list_access_keys({'UserName' => user['UserName']}).body["AccessKeys"]
                obj = Crack::JSON.parse user.to_json
                obj["account_id"] = @account_id
                obj["access_keys"] = access_keys

                primary_key = make_primary_key(@account_id, user['UserId'])
                @log.info "#{primary_key}"

                @synchronizer.process primary_key, obj

              end
            end

          when "AwsAuditor::AwsIamGroupPolicies"

            obj = Hash.new
            obj["account_id"] = @account_id

            compute.list_groups.body["Groups"].each do |group|
              obj = group
              obj["account_id"] = @account_id
              obj["policies"] = Array.new

              compute.list_group_policies(group["GroupName"]).body["PolicyNames"].each do |policy|

                begin
                  policy_obj = Crack::JSON.parse CGI::unescape(compute.get_group_policy(policy, group["GroupName"]).body["PolicyDocument"])

                  obj["policies"] << policy_obj

                rescue Exception => e
                  @log.warn "Unable to Crack policy >#{compute.get_group_policy(policy, group["GroupName"]).body["PolicyDocument"]}<"
                end

              end

              primary_key = make_primary_key(@account_id, group["GroupId"])
              @log.info "#{primary_key}"

              @synchronizer.process primary_key, obj

            end

        end


      end

      @log.info @synchronizer.stats

    end

    @ended_at = Time.now

  end

  class AwsIamGroupPolicies < AwsObject
    def initialize args
      super args
    end
  end

  class AwsIamUsers < AwsObject
    def initialize args
      super args
    end
  end

  class AwsElbs < AwsObject
    def initialize args
      super args
    end
  end
  class AwsSnapshots < AwsObject
    def initialize args
      super args
    end
  end

  class AwsVolumes < AwsObject
    def initialize args
      super args
    end
  end

  class AwsSubnets < AwsObject
    def initialize args
      super args
    end
  end

  class AwsSecurityGroups < AwsObject
    def initialize args
      super args
    end
  end

  class AwsInstances < AwsObject
    def initialize args
      super args
    end
  end


end

