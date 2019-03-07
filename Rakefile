#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'engine_cart/rake_task'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

desc "Run continuous integration build"
task ci: ['engine_cart:generate'] do
  Rake::Task['spec'].invoke
end

desc 'Run continuous integration build'
task ci: ['rubocop', 'spec']

task default: :ci

# -----

require_relative 'config/application'

# Load rake tasks for development and testing
unless Rails.env.production?
  require 'solr_wrapper/rake_task'
  Dir.glob(File.expand_path('tasks/*.rake', __dir__)).each do |f|
    load(f)
  end
  require 'coveralls/rake/task'
  Coveralls::RakeTask.new
end

Rails.application.load_tasks
