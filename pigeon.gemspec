# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pigeon/version'

Gem::Specification.new do |gem|
  gem.name          = "pigeon"
  gem.version       = Pigeon::VERSION
  gem.authors       = ["Ary Borenszweig", "Gustavo Giráldez"]
  gem.email         = ["aborenszweig@manas.com.ar", "ggiraldez@manas.com.ar"]
  gem.description   = %q{Channel management frontend for Nuntium & Verboice}
  gem.summary       = %q{}
  gem.homepage      = ""

  gem.add_dependency 'rails', '~> 3.2.12'
  gem.add_dependency 'nuntium_api', '~> 0.19'
  gem.add_dependency 'verboice', '0.6.0'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
