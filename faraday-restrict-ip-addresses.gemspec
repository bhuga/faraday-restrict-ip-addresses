require_relative 'lib/faraday/restrict_ip_addresses/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'faraday', '~> 0.9'
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.authors = ["Ben Lavender"]
  spec.description = %q{Restrict the IP addresses Faraday will connect to}
  spec.email = ['bhuga@github.com']
  spec.files = %w(UNLICENSE README.md faraday-restrict-ip-addresses.gemspec)
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("spec/**/*")
  spec.homepage = 'https://github.com/bhuga/faraday-restrict-ip-addresses'
  spec.licenses = ['Unlicense']
  spec.name = 'faraday-restrict-ip-addresses'
  spec.require_paths = ['lib']
  spec.required_rubygems_version = '>= 1.3.5'
  spec.summary = spec.description
  spec.test_files += Dir.glob("spec/**/*")
  spec.version = Faraday::RestrictIPAddresses::VERSION
end
