# encoding: UTF-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'version'

Gem::Specification.new do |s|
  s.name          = 'transhumance'
  s.version       = Transhumance::VERSION
  s.summary       = %q{Rails migration with low contention, mirroring of data, and schema changes friendly}
  s.description   = %q{Rails migration with low contention, mirroring of data, and schema changes friendly}
  s.authors       = ['Thibault Gautriaud', 'Julien Letessier']
  s.email         = ['tgautriaud@housetrip.com', 'jletessier@housetrip.com']
  s.homepage      = 'https://github.com/hubb/transhumance'
  s.license       = 'MIT'

  s.files         = Dir.glob('lib/**/*')
  s.test_files    = s.files.grep(%r{^spec})
  s.require_paths = ['lib']

  s.add_runtime_dependency 'activerecord', '~> 2.3.18'
  s.add_dependency 'mysql2', '<0.3'

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-nav'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'guard-bundler'
end
