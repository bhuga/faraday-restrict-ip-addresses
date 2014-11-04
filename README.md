Faraday::RestrictIPAddresses
============================

Prevent Faraday from hitting an arbitrary list of IP addresses, with helpers
for RFC 1918 networks, RFC 6890 networks, and localhost.

System DNS facilities are used, so lookups should be cached instead of making
another request. Addresses are invalid if a host has has at least one invalid
DNS entry.

Usage
=====

```ruby
faraday = Faraday.new do |builder|
  builder.request :url_encoded
  builder.request :restrict_ip_addresses, deny_rfc6890: true,
                                          allow_localhost: true,
                                          deny: ['8.0.0.0/8',
                                                 '224.0.0.0/7'],
                                          allow: ['192.168.0.0/24']
  builder.adapter Faraday.default_adapter
end

faraday.get 'http://www.badgerbadgerbadger.com' # 150.0.0.150 or something
# => cool

faraday.get 'http://malicious-callback.com'      # 172.0.0.150, maybe a secret internal server? Maybe not?
# => raises Faraday::RestrictIPAddresses::AddressNotAllowed
```

Permit/denied order is:

 * All addresses are allowed, except
 * Addresses that are denied, except
 * Addresses that are allowed.

#### Author

Dat @bhuga with shoutouts to @mastahyeti's [gist.](https://gist.github.com/mastahyeti/8497793)

#### UNLICENSE

It's right there.
