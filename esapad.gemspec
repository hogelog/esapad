# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'esapad/version'

Gem::Specification.new do |spec|
  spec.name          = "esapad"
  spec.version       = Esapad::VERSION
  spec.authors       = ["hogelog"]
  spec.email         = ["konbu.komuro@gmail.com"]

  spec.summary       = %q{esa.io tools.}
  spec.description   = %q{esa.io tools.}
  spec.homepage      = "https://github.com/hogelog/esapad"
  spec.license       = "MIT"

  spec.metadata['allowed_push_host'] = "https://rubygems.org"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "esa"
  spec.add_dependency "json"
  spec.add_dependency "denv"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
end
