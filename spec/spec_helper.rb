# encoding: UTF-8

ENV['RACK_ENV'] ||= 'test'

# Dependencies
require 'rspec'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'logger'
require 'active_record'

# Gem
require File.join('./lib', 'transhumance')

# Seed the db
Rake.application.init
Rake.application.load_rakefile
Rake.application['db:seed'].invoke
