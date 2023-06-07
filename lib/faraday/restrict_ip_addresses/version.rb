require 'faraday'
module Faraday
  class RestrictIPAddresses < Faraday::Middleware
    VERSION = '0.2.0'
  end
end
