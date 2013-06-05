# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pigeon/version'

Gem::Specification.new do |gem|
  gem.name          = "instedd-pigeon"
  gem.version       = Pigeon::VERSION
  gem.authors       = ["Ary Borenszweig", "Gustavo Giráldez"]
  gem.email         = ["aborenszweig@manas.com.ar", "ggiraldez@manas.com.ar"]
  gem.description   = %q{Channel management frontend for Nuntium & Verboice}
  gem.summary       = %q{This gem handles creating, updating and destroying channels in Nuntium and Verboice for your Rails application.}
  gem.homepage      = "https://bitbucket.org/instedd/pigeon"

  gem.add_dependency 'rails', '~> 3.2'
  gem.add_dependency 'twitter_oauth'
  gem.add_dependency 'rest-client'
  gem.add_dependency 'json'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
