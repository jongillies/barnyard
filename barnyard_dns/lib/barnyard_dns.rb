require "barnyard_dns/version"

require "barnyard_harvester"
require "json"
require "dnsruby"

module BarnyardDns

  class DnsObject

    attr_reader :synchronizer, :began_at, :ended_at

    def initialize(args)

      @began_at = Time.now

      @debug = args.fetch(:debug) { false }
      @log = args.fetch(:logger) { Logger.new(STDOUT) }

      @zone = args.fetch(:zone) { raise "You must provide the :zone to transfer." }

      @log.debug JSON.pretty_generate(args)

      @synchronizer = BarnyardHarvester::Sync.new(args)

      @synchronizer.run do

        zt = Dnsruby::ZoneTransfer.new
        zt.transfer_type = Dnsruby::Types.AXFR
        zone = zt.transfer(@zone)

        next if zone.nil?

        zone.each do |rec|

          @synchronizer.process rec.name, rec

        end

      end

      @log.info @synchronizer.stats

    end

    @ended_at = Time.now

  end

end

