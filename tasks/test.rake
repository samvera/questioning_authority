# frozen_string_literal: true

require 'rspec/core'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

namespace :qa do
  desc 'Run specs'
  RSpec::Core::RakeTask.new(:rspec) do |t|
    t.rspec_opts = ['--color', '--backtrace']
  end

  namespace :travis do
    desc 'Execute Continuous Integration build (docs, tests with coverage)'
    task rspec: :environment do
      Rake::Task['db:migrate'].invoke
      Rake::Task['qa:rspec'].invoke
    end

    desc 'Run style checker'
    RuboCop::RakeTask.new(:rubocop) do |task|
      task.requires << 'rubocop-rspec'
      task.fail_on_error = true
    end
  end
end
