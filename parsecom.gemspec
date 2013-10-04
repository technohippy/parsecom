# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'parse/version'

Gem::Specification.new do |gem|
  gem.name          = "parsecom"
  gem.version       = Parse::VERSION
  gem.authors       = ["Ando Yasushi"]
  gem.email         = ["andyjpn@gmail.com"]
  gem.description   = %q{Pure Ruby version of parse.com client. This library allows you to access straightforwardly to parse.com REST API.}
  gem.summary       = %q{Pure Ruby version of parse.com client}
  gem.homepage      = "https://github.com/technohippy/parsecom"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
 
  gem.add_development_dependency "rspec"
end
