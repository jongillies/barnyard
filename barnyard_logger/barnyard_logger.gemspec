# -*- encoding: utf-8 -*-
require File.expand_path('../lib/barnyard_logger/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jon Gillies"]
  gem.email         = ["supercoder@gmail.com"]
  gem.description   = %q{Deliver subscriptions to queues.}
  gem.summary       = %q{Help}
  gem.homepage    = "https://github.com/jongillies/barnyard/tree/master/barnyard_logger"

  gem.rubyforge_project = "barnyard_logger"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "barnyard_logger"
  gem.require_paths = ["lib"]
  gem.version       = BarnyardMarket::VERSION

  # specify any dependencies here; for example:
  gem.add_development_dependency "rspec"
  gem.add_runtime_dependency "aws-sdk"
  gem.add_runtime_dependency "barnyard_ccfeeder"
  gem.add_runtime_dependency "barnyard_harvester"
  gem.add_runtime_dependency "crack"
  gem.add_runtime_dependency "uuid"


end
