# encoding: UTF-8

require 'rspec/core/rake_task'
require 'yaml'
require 'active_record'
require 'benchmark'

RSpec::Core::RakeTask.new(:spec)

task :default  => :spec

namespace :db do
  desc "Drop and create the test database"
  task :create do
    env_config = config.fetch(ENV['RACK_ENV']) { raise "LoadError: Unknown environment #{ENV['RACK_ENV']}" }
    ActiveRecord::Base.establish_connection(config[ENV['RACK_ENV']].merge('database' => nil))
    ActiveRecord::Base.connection.recreate_database(config[ENV['RACK_ENV']]['database'])
  end

  desc "Loads test data"
  task :seed => [:create, "schema:load"] do
    ActiveRecord::Base.establish_connection(config[ENV['RACK_ENV']])

    (1..100).each do |val|
      ActiveRecord::Base.connection.insert(%Q{
        INSERT INTO sheeps
        VALUES ("#{val}",
                "#{rand(100)}",
                "#{rand(100)}.#{rand(10000)}",
                "sheepfold_#{rand(5)}",
                "#{random_string(255)}",
                "#{Time.current.to_s(:db)}",
                "#{Time.current.to_s(:db)}")
      })
    end
  end

  namespace :schema do
    desc "Creates tables and columns following spec/support/schema.rb"
    task :load do
      ActiveRecord::Base.establish_connection(config[ENV['RACK_ENV']])
      load(File.expand_path('schema.rb', 'spec/support'))
    end
  end
end

def config
  @config ||= YAML::load(IO.read(File.expand_path('database.yml', 'spec/support')))
end

def self.random_string(size = 25)
  (0..size).map { (65+rand(26)).chr }.join
end
