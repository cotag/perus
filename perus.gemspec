# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'perus/version'

Gem::Specification.new do |spec|
    spec.name          = 'perus'
    spec.version       = Perus::VERSION
    spec.authors       = ['Will Cannings']
    spec.email         = ['me@willcannings.com']

    spec.summary       = 'Simple system overview server'
    spec.homepage      = 'https://github.com/cotag/perus'
    spec.license       = 'MIT'

    spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    spec.bindir        = 'exe'
    spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
    spec.require_paths = ['lib']

    spec.add_development_dependency 'bundler', '~> 1.10'
    spec.add_development_dependency 'rake', '~> 10.0'
    spec.add_development_dependency 'rspec'

    spec.add_dependency 'concurrent-ruby', '~> 0.8'
    spec.add_dependency 'faye-websocket', '~> 0.10'
    spec.add_dependency 'websocket-driver', '>= 0.6.4'
    spec.add_dependency 'rest-client', '~> 2.1.0'
    spec.add_dependency 'sinatra', '~> 1.4'
    spec.add_dependency 'sinatra-contrib', '~> 1.4'
    spec.add_dependency 'sequel', '~> 4.23'
    spec.add_dependency 'iniparse', '~> 1.4'
    spec.add_dependency 'thin', '~> 1.6'
    spec.add_dependency 'chronic_duration', '~> 0.10'
end
