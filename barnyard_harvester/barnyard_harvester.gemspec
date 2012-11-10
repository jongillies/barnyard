# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "barnyard_harvester/version"

Gem::Specification.new do |gem|
  gem.name        = "barnyard_harvester"
  gem.version     = BarnyardHarvester::VERSION
  gem.authors     = ["Jon Gillies"]
  gem.email       = %w(supercoder@gmail.com)
  gem.description = %q{Performs harvests on data sources and detects adds, changes and deletes.}
  gem.summary     = %q{Please check the README.md for more information.}
  gem.homepage    = "https://github.com/jongillies/barnyard/tree/master/barnyard_harvester"

  gem.rubyforge_project = "barnyard_harvester"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = %w(lib)

  # specify any dependencies here; for example:
  gem.add_development_dependency "rspec"
  gem.add_runtime_dependency "resque"
  gem.add_runtime_dependency "crack"
  gem.add_runtime_dependency "json"
  gem.add_runtime_dependency "uuid"

end
