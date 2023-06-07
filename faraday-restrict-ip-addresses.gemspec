Gem::Specification.new do |spec|
  spec.version = '0.2.0' # don't forget to update version.rb

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

  spec.add_dependency 'faraday', '~> 1.0'
end
