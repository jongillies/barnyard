# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "barnyard_harvester/version"

Gem::Specification.new do |s|
  s.name        = "barnyard_harvester"
  s.version     = BarnyardHarvester::VERSION
  s.authors     = ["Jon Gillies"]
  s.email       = ["supercoder@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Performs Harvests}
  s.description = %q{Performs Harvests really well}

  s.rubyforge_project = "harvester"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_runtime_dependency "resque"
  s.add_runtime_dependency "crack"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "uuid"

end
