# encoding: UTF-8

require './lib/version'

Gem::Specification.new do |s|
	s.name   			= 'transhumance'
	s.version			= Transhumance::VERSION
	s.date   			= '2013-09-05'

	s.summary			= 'Be nice to your DB, migrate your data with care'
	s.description = 'Rails migration with low contention, mirroring of data, and schema changes friendly'

	s.authors     = ['Thibault Gautriaud', 'Julien Letessier']
	s.email				= ['tgautriaud@housetrip.com', 'jletessier@housetrip.com']
	s.homepage    = 'https://github.com/hubb/transhumance'

	s.files       = Dir.glob('lib/**/*')
	s.test_files  = s.files.grep(%r{^spec})

	s.add_runtime_dependency 'activerecord'

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-nav'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'guard-bundler'
end
