require 'faraday'
require 'faraday/restrict_ip_addresses/version'
require 'ipaddr'

module Faraday
  module RestrictIPAddresses
    class AddressNotAllowed < Faraday::Error::ClientError ; end

    class Middleware < Faraday::Middleware

      RFC_1918_NETWORKS = %w(
        127.0.0.0/8
        10.0.0.0/8
        172.16.0.0/12
        192.168.0.0/16
      ).map { |net| IPAddr.new(net) }

      RFC_6890_NETWORKS = RFC_1918_NETWORKS + [
        '0.0.0.0/8',         #  "This" Network [RFC1700, page 4]
        '100.64.0.0/10',     #  Shared address space [6598, 6890]
        #'128.0.0.0/16',      #  Reserved in 3330, not in 6890, has been assigned
        '169.254.0.0/16',    #  Link Local [3927, 6890]
        # '191.255.0.0/16'   #  Reserved in 3330, not in 6890, has been assigned
        '192.0.0.0/24',      #  Reserved but subject to allocation [6890]
        '192.0.0.0/29',      #  DS-Lite                        [6333, 6890]. Redundant with above, included for completeness.
        '192.0.2.0/24',      #  Documentation                  [5737, 6890]
        '192.88.99.0/24',    #  6to4 Relay Anycast             [3068, 6890]
        '198.18.0.0/15',     #  Network Interconnect Device Benchmark Testing [2544, 6890]
        '198.51.100.0/24',   #  Documentation                  [5737, 6890]
        '203.0.113.0/24',    #  Documentation                  [5737, 6890]
        '224.0.0.0/4',       #  Multicast                      [11112]
        '240.0.0.0/4',       #  Reserved for Future Use        [6890]
        '255.255.255.255/32' #  Reserved for Future Use        [6890]
      ].map { |net| IPAddr.new(net) }

      def initialize(app, options = {})
        super(app)
        @denied_networks   = (options[:deny] || []).map  { |n| IPAddr.new(n) }
        @allowed_networks  = (options[:allow] || []).map { |n| IPAddr.new(n) }

        @denied_networks += RFC_1918_NETWORKS if options[:deny_rfc1918]
        @denied_networks += RFC_6890_NETWORKS if options[:deny_rfc6890]
        @denied_networks.uniq!
        @allowed_networks += [IPAddr.new('127.0.0.1')] if options[:allow_localhost]
      end

      def call(env)
        raise AddressNotAllowed.new "Address not allowed for #{env[:url]}" if denied?(env)
        @app.call(env)
      end

      def denied?(env)
        addresses(env[:url].hostname).any? { |a| denied_ip?(a) }
      end

      def denied_ip?(address)
        @denied_networks.any? { |net| net.include?(address) and !allowed_ip?(address) }
      end

      def allowed_ip?(address)
        @allowed_networks.any? { |net| net.include? address }
      end

      def addresses(hostname)
        Addrinfo.getaddrinfo(hostname, nil, :UNSPEC, :STREAM).map { |a| IPAddr.new(a.ip_address) }
      rescue SocketError => e
        # In case of invalid hostname, return an empty list of addresses
        []
      end
    end

    Request.register_middleware restrict_ip_addresses: lambda { Faraday::RestrictIPAddresses::Middleware }
  end
end
