$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "qa/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "qa"
  s.version     = Qa::VERSION
  s.authors     = ["Stephen Anderson","Don Brower","Jim Coble","Mike Dubin","Randall Floyd","Eric James","Mike Stroming","Adam Wead"]
  s.email       = ["amsterdamos@gmail.com"]
  s.homepage    = "https://github.com/projecthydra/questioning_authority"
  s.summary     = "You should question your authorities."
  s.description = "Provides a set of uniform RESTful routes to query any controlled vocabulary or set of authority terms."
  s.license     = "APACHE-2"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  s.add_dependency "curb"
  s.add_dependency "rest-client"
  s.add_dependency "nokogiri", "~> 1.6.0"
  s.add_dependency "activerecord-import", ">= 0.4.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "webmock"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "debugger"
end
