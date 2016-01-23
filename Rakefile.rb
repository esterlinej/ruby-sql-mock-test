# -*- ruby -*-

require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.pattern = 'features/test*.rb'
end

# vim: syntax=ruby
