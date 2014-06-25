#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'engine_cart/rake_task'
EngineCart.rails_options = '--skip-spring'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc "Run continuous integration build"
task :ci => ['engine_cart:generate'] do
  Rake::Task['spec'].invoke
end

task :default => :ci
