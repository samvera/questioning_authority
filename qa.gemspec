lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "qa/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "qa"
  s.version     = Qa::VERSION
  s.authors     = ["Stephen Anderson", "Don Brower", "Jim Coble", "Mike Dubin", "Randall Floyd", "Eric James", "Mike Stroming", "Adam Wead", "E. Lynette Rayle"]
  s.email       = ["amsterdamos@gmail.com"]
  s.homepage    = "https://github.com/projecthydra/questioning_authority"
  s.summary     = "You should question your authorities."
  s.description = "Provides a set of uniform RESTful routes to query any controlled vocabulary or set of authority terms."
  s.license     = "APACHE-2"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'activerecord-import'
  s.add_dependency 'deprecation'
  s.add_dependency 'faraday'
  s.add_dependency 'nokogiri', '~> 1.6'
  s.add_dependency 'rails', '~> 5.0'
  s.add_dependency 'rdf'

  # the hyrax style guide is based on `bixby`. see `.rubocop.yml`
  s.add_development_dependency 'bixby', '~> 1.0.0'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'engine_cart', '~> 0.8'
  s.add_development_dependency 'linkeddata'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'swagger-docs'
  s.add_development_dependency 'webmock'
end
