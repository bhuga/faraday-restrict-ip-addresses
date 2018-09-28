require 'faraday/restrict_ip_addresses'
require 'spec_helper'

describe Faraday::RestrictIPAddresses::Middleware do
  def middleware(opts = {})
    @rip = described_class.new(lambda{|env| env}, opts)
  end

  def allowed(*addresses)
    url = URI.parse("http://test.com")
    ips = addresses.map { |add| Addrinfo.tcp(add, nil) }

    Addrinfo.expects(:getaddrinfo).with(url.host, nil, :UNSPEC, :STREAM).returns(ips)

    env = { url: url }
    @rip.call(env)
  end

  def denied(*addresses)
    expect(-> { allowed(*addresses) }).to raise_error(Faraday::RestrictIPAddresses::AddressNotAllowed)
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

    it "disallows addresses when any IP address is disallowed" do
      middleware deny: ["8.0.0.0/8"]

      denied '10.0.0.10', '8.8.8.8'
      allowed '10.0.0.10'
      denied '10.0.0.10', '8.8.8.8'
    end

    it "blacklists RFC1918 addresses" do
      middleware deny_rfc1918: true

      allowed '5.5.5.5'
      denied  '127.0.0.1'
      denied  '192.168.15.55'
      denied  '10.0.0.252'
    end

    it "blacklists RFC6890 addresses" do
      middleware deny_rfc6890: true

      allowed '5.5.5.5'
      denied  '240.15.15.15'
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

    it "blacklists normalized values" do
      middleware deny_rfc6890: true,
                 allow_localhost: false

      denied '0'
      denied '0x0'
      denied '0x00.0'
      denied '00.0'
      denied '127.0.0.1'
      denied '0x7f.1'
      denied '0177.1'
    end

    it "allows addresses for which DNS fails" do
      middleware deny_rfc1918: true,
                 deny: ['8.0.0.0/8'],
                 allow: ['8.5.0.0/24', '192.168.14.0/24']
      url = URI.parse("http://thisisanonexistinghostname.com")
      Addrinfo.expects(:getaddrinfo).with(url.host, nil, :UNSPEC, :STREAM).raises(SocketError)
      @rip.call(url: url)
    end

    it "works for IPV6 localhost addresses" do
      middleware allow_localhost: false,
                 deny: ['::1']

      denied '::1'
      denied '0:0:0:0:0:0:0:1'
    end
end
