desc "Respect your authorities! Runs tests with Webmock turned off"
task :respect => :environment do
  ENV["WEBMOCK"] ||= "disabled"
  Rake::Task["spec"].invoke
end