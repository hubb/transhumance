# encoding: UTF-8

Gem::Specification.new do |s|
	s.name   			= 'Transhumance'
	s.version			= Transhumance::VERSION
	s.date   			= '2013-09-05'

	s.summary			= 'Be nice to your DB, migrate your data with care'
	s.description = 'Rails migration with low contention, mirroring of data, and schema changes friendly'

	s.authors     = ['Thibault Gautriaud', 'Julien Letessier']
	s.email				= ['tgautriaud@housetrip.com', 'jletessier@housetrip.com']
	s.homepage    = 'https://github.com/hubb/transhumance'

	s.files       = Dir.glob('lib/**/*.rb')
	s.test_files  = Dir.glob('spec/**/*_spec.rb')
end
