# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gnuplot/version'

Gem::Specification.new do |spec|
  spec.name          = 'gnuplot'
  spec.version       = Gnuplot::VERSION
  spec.authors       = ['Ivan Evgrafov']
  spec.email         = ['dilcom3107@gmail.com']

  spec.summary       = 'Pilot ruby bindings for gnuplot'
  spec.description   = 'Renewed ruby bindings for gnuplot. Started at GSoC 2015.'
  spec.homepage      = 'https://github.com/dilcom/pilot-gnuplot'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(/^(test|spec|features|samples|work)\//) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'rdoc', '~> 4.2'
  spec.add_development_dependency 'rubocop', '~> 0.29'
end
