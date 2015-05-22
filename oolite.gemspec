# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oolite/version'

Gem::Specification.new do |spec|
  spec.name          = "oolite"
  spec.version       = Oolite::VERSION
  spec.authors       = ["Jeff McAffee"]
  spec.email         = ["jeff@ktechsystems.com"]
  spec.summary       = %q{Utility scripts for the Oolite game}
  spec.description   = %q{Utility scripts for tracking markets and assisting with trading in the Oolite game.}
  spec.homepage      = "https://github.com/jmcaffee/oolite"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"

  spec.add_runtime_dependency "nokogiri", "~> 1.6"
end
