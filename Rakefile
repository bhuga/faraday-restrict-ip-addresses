task default: :spec

task :spec do
  sh "rspec"
end

task release: %i[clean spec git gem] do
  sh "echo gem push *.gem"

  sh "git tag v%s" % [Faraday::RestrictIPAddresses::VERSION]
  sh "git push --tags"
end

task gem: %i[clean git] do
  version = ENV["VERSION"] || ENV["V"]
  abort "Specify VERSION=x.y.z to release" unless version

  require_relative "lib/faraday/restrict_ip_addresses/version"
  act = Faraday::RestrictIPAddresses::VERSION

  abort "Version specified doesn't match %p" % [act] unless act == version

  sh "gem build"
end

task :git do
  status = `git status --porcelain`
  abort "git looks dirty\n#{status}" unless status.lines.empty?
end

task :clean do
  rm_f Dir["**/*~", "*.gem"]
end
