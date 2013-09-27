# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kannel_monitor/version'

Gem::Specification.new do |spec|
  spec.name          = "kannel_monitor"
  spec.version       = KannelMonitor::VERSION
  spec.authors       = ["shaiju"]
  spec.email         = ["shaiju@mobme.in"]
  spec.description   = %q{Gem for monitor kannel}
  spec.summary       = %q{Gem for monitoring kannel }
  spec.homepage      = "https://github.com/shaijunonu/kannel-monitor"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  #spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.executables   = ['kannel_monitor']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "sendmail", "~> 0.0.1"
  spec.add_development_dependency  "pony", "~> 1.5.1"


end
