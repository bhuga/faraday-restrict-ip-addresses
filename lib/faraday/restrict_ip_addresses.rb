require 'faraday'
require 'ipaddr'

module Faraday
  class RestrictIPAddresses < Faraday::Middleware
    class AddressNotAllowed < Faraday::Error::ClientError ; end
    VERSION = '0.0.1'

    RFC_1918_NETWORKS = %w(
      127.0.0.0/8
      10.0.0.0/8
      172.16.0.0/12
      192.168.0.0/16
    ).map { |net| IPAddr.new(net) }

    def initialize(app, options = {})
      super(app)
      @denied_networks   = (options[:deny] || []).map  { |n| IPAddr.new(n) }
      @allowed_networks  = (options[:allow] || []).map { |n| IPAddr.new(n) }

      @denied_networks += RFC_1918_NETWORKS if options[:deny_rfc1918]
      @allowed_networks += [IPAddr.new('127.0.0.1')] if options[:allow_localhost]
    end

    def call(env)
      raise AddressNotAllowed.new "Address not allowed for #{env[:url]}" if denied?(env)
      @app.call(env)
    end

    def denied?(env)
      addresses(env[:url].host).any? { |a| denied_ip?(a) }
    end

    def denied_ip?(address)
      @denied_networks.any? { |net| net.include?(address) and !allowed_ip?(address) }
    end

    def allowed_ip?(address)
      @allowed_networks.any? { |net| net.include? address }
    end

    def addresses(hostname)
      Socket.gethostbyname(hostname).map { |a| IPAddr.new_ntoh(a) rescue nil }.compact
    end
  end

  register_middleware restrict_ip_addresses: lambda { RestrictIPAddresses }
end
