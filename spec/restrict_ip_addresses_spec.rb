require 'faraday/restrict_ip_addresses'
require 'spec_helper'

describe Faraday::RestrictIPAddresses do
  def middleware(opts = {})
    @rip = described_class.new(lambda{|env| env}, opts)
  end

  def allowed(string_address)
    url = URI.parse("http://test.com")
    ip  = IPAddr.new(string_address).hton

    Socket.expects(:gethostbyname).with(url.host).returns(['garbage', [], 30, ip])

    env = { url: url }
    @rip.call(env)
  end

  def denied(string_address)
    expect(-> { allowed(string_address) }).to raise_error(Faraday::RestrictIPAddresses::AddressNotAllowed)
  end

    it "defaults to allowing everything" do
      middleware

      allowed '10.0.0.10'
      allowed '255.255.255.255'
    end

    it "allows disallowing addresses" do
      middleware deny: ["8.0.0.0/8"]

      allowed '7.255.255.255'
      denied  '8.0.0.1'
    end

    it "blacklists RFC1918 addresses" do
      middleware deny_rfc1918: true

      allowed '5.5.5.5'
      denied  '127.0.0.1'
      denied  '192.168.15.55'
      denied  '10.0.0.252'
    end

    it "allows exceptions to disallowed addresses" do
      middleware deny_rfc1918: true,
                 allow: ["192.168.0.0/24"]

      allowed '192.168.0.15'
      denied  '192.168.1.0'
    end

    it "has an allow_localhost exception" do
      middleware deny_rfc1918: true,
                 allow_localhost: true
      denied  '192.168.0.15'
      allowed '127.0.0.1'
      denied  '127.0.0.5'
    end

    it "lets you mix and match your denied networks" do
      middleware deny_rfc1918: true,
                 deny: ['8.0.0.0/8'],
                 allow: ['8.5.0.0/24', '192.168.14.0/24']
      allowed '8.5.0.15'
      allowed '192.168.14.14'
      denied  '8.8.8.8'
      denied  '192.168.13.14'
    end

end

