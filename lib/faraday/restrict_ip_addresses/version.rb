module Faraday
  class Middleware; end # so we don't have to load faraday gem to get version
  class RestrictIPAddresses < Faraday::Middleware
    VERSION = '0.3.0'
  end
end
