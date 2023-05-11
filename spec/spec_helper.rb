$:.unshift 'lib'
require 'faraday/restrict_ip_addresses'
require 'pry'
require 'mocha'

RSpec.configure do |config|
  config.mock_with :mocha
end
