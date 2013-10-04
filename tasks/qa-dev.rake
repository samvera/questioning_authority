desc "Create the test rails app"
task :generate do
  unless File.exists?("spec/internal/Rakefile")
    puts "Generating rails app"
    system "rails new spec/internal"
    puts "Updating gemfile"
    `echo "gem 'qa', :path=>'../../../questioning_authority'" >> spec/internal/Gemfile`
    `echo "gem 'rspec-rails'" >> spec/internal/Gemfile`
    `echo "gem 'webmock'" >> spec/internal/Gemfile`
    puts "Copying generator"
    `cp -r spec/support/lib/generators spec/internal/lib`
    Bundler.with_clean_env do
      within_test_app do
        puts "running test_app_generator"
        system "rails generate test_app"
        puts "Bundle install"
        system "bundle install"
        puts "running migrations"
        system "rake qa:install:migrations db:migrate db:test:prepare"
      end
    end
  end
  puts "Done generating test app"
end

desc "Clean out the test rails app"
task :clean do
  Rake::Task["stop"].invoke
  puts "Removing sample rails app"
  system "rm -rf spec/internal"
end

desc "Start the test rails app"
task :start do
  Bundler.with_clean_env do
    within_test_app do
      puts "Starting test app"
      system "rails server -d"
    end
  end
end

desc "Stop the test rails app"
task :stop do
  pid_file = "tmp/pids/server.pid"
  within_test_app do
    if File.exists?(pid_file)
      pid = File.read(pid_file)
      puts "Stopping pid #{pid}"
      system "kill -2 #{pid}"
    end
  end
end

desc "Do a full run of tests"
task :spec do
  Rake::Task["generate"].invoke
  Rake::Task["generate"].reenable
  Bundler.with_clean_env do
    within_test_app do
      Rake::Task['rspec'].invoke
    end
  end
end

desc "Run rspec tests in the spec directory"
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = '../**/*_spec.rb'
  t.rspec_opts = "--colour -I ../"
end

def within_test_app
  return unless File.exists?("spec/internal")
  FileUtils.cd("spec/internal")
  yield
  FileUtils.cd("../..")
end