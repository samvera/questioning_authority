$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "questioning_authority/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "questioning_authority"
  s.version     = QuestioningAuthority::VERSION
  s.authors     = ["Adam Wead"]
  s.email       = ["amsterdamos@gmail.com"]
  s.homepage    = "https://github.com/projecthydra/questioning_authority"
  s.summary     = "Interface for different vocabulary authorities."
  s.description = "Interface for different vocabulary authorities."

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec"
end
