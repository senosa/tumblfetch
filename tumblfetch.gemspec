# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tumblfetch/version'

Gem::Specification.new do |spec|
  spec.name          = "tumblfetch"
  spec.version       = Tumblfetch::VERSION
  spec.authors       = ["Sensuke Osawa"]
  spec.email         = ["senosa@gmail.com"]
  spec.summary       = %q{Fetch images from tumblr.}
  spec.description   = %q{Fetch images from tumblr.}
  spec.homepage      = "https://github.com/senosa/tumblfetch"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end