# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "barnyard_dns/version"

Gem::Specification.new do |gem|
  gem.name          = "barnyard_dns"
  gem.version       = BarnyardDns::VERSION
  gem.authors       = ["Jon Gillies"]
  gem.email         = %w(supercoder@gmail.com)
  gem.description   = %q{This gem provides access to the DNS objects for use with BarnyardHarvester.}
  gem.summary       = %q{Please check the README.md for more information.}
  gem.homepage      = "https://github.com/jongillies/barnyard/tree/master/barnyard_dns"

  gem.rubyforge_project = "barnyard_dns"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = %w(lib)

  # specify any dependencies here; for example:
  gem.add_development_dependency "rspec"
  gem.add_runtime_dependency "barnyard_harvester"
  gem.add_runtime_dependency "dnsruby"

end
