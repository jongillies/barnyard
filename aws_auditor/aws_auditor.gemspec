# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws_auditor/version'

Gem::Specification.new do |gem|
  gem.name          = "aws_auditor"
  gem.version       = AwsAuditor::VERSION
  gem.authors       = ["Jon Gillies"]
  gem.email         = ["supercoder@gmail.com"]
  gem.description   = %q{Write a gem description}
  gem.summary       = %q{Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]


  # specify any dependencies here; for example:
  gem.add_development_dependency "rspec"
  gem.add_runtime_dependency "harvester"
  gem.add_runtime_dependency "fog"

end
