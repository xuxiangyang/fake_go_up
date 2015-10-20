# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fake_go_up/version'

Gem::Specification.new do |spec|
  spec.name          = "fake_go_up"
  spec.version       = FakeGoUp::VERSION
  spec.authors       = ["xuxiangyang"]
  spec.email         = ["xxy@creatingev.com"]

  spec.summary       = %q{fake go up}
  spec.description   = %q{fake go up}
  spec.homepage      = "https://github.com/xuxiangyang/fake_go_up"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "pid_lock", "~> 0.0.2"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit", "~> 3.1.3"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "hiredis", "~> 0.5.2"
  spec.add_development_dependency 'redis-namespace', '~> 1.5.0'
end
