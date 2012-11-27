# -*- encoding: utf-8 -*-
require File.expand_path('../lib/barnyard_ccfeeder/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jon Gillies"]
  gem.email         = ["supercoder@gmail.com"]

  gem.description   = %q{Feeds the Cache Cow}
  gem.summary       = %q{REST API to the Cache Cow}

  gem.homepage    = "https://github.com/jongillies/barnyard/tree/master/barnyard_ccfeeder"

  gem.rubyforge_project = "barnyard_ccfeeder"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "barnyard_ccfeeder"
  gem.require_paths = ["lib"]
  gem.version       = BarnyardCcfeeder::VERSION

  # specify any dependencies here; for example:
  gem.add_development_dependency "rspec"
  gem.add_runtime_dependency "aws-sdk"
  gem.add_runtime_dependency "logger"
  gem.add_runtime_dependency "rest-client"
  gem.add_runtime_dependency "crack"
  gem.add_runtime_dependency "json"

end
