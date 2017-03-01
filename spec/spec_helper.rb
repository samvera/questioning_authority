require 'linkeddata'
require 'json'
require 'engine_cart'
require 'simplecov'
require 'coveralls'
require 'byebug' unless ENV['TRAVIS']

ENV["RAILS_ENV"] ||= "test"

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start "rails"
SimpleCov.command_name "spec"
EngineCart.load_application!
Coveralls.wear!

require 'rspec/rails'
require 'webmock/rspec'
require 'pry'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = File.expand_path("../fixtures", __FILE__)

  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Disable Webmock if we choose so we can test against the authorities, instead of their mocks
  WebMock.disable! if ENV["WEBMOCK"] == "disabled"

  config.infer_spec_type_from_file_location!
end

def webmock_fixture(fixture)
  File.new File.expand_path(File.join("../fixtures", fixture), __FILE__)
end

# returns the file contents
def load_fixture_file(fname)
  File.open(Rails.root.join("spec/fixtures", fname)) do |f|
    return f.read
  end
end
