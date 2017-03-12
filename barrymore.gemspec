# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'barrymore/version'

Gem::Specification.new do |spec|
  spec.name          = 'barrymore'
  spec.version       = Barrymore::VERSION
  spec.authors       = ['Dmitriy Non']
  spec.email         = ['non.dmitriy@gmail.com']

  spec.summary       = 'Barrymore - DSL for defining chat bot commands (like telegram bot commands)'
  spec.homepage      = 'https://github.com/Nondv/barrymore'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '0.46.0'
end
