# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'barnyard_aws/version'

Gem::Specification.new do |gem|
  gem.name          = "BarnyardAws"
  gem.version       = BarnyardAws::VERSION
  gem.authors       = ["Jon Gillies"]
  gem.email         = ["supercoder@gmail.com"]
  gem.description   = %q{description}
  gem.summary       = %q{summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]


  # specify any dependencies here; for example:
  gem.add_development_dependency "rspec"
  gem.add_runtime_dependency "barnyard_harvester"
  gem.add_runtime_dependency "fog"

end
