require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "./spec/test_app_templates"

  def update_app
    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  def run_qa_installer
    generate "qa:install"
  end

  def run_migrations
    rake "qa:install:migrations"
    rake "db:migrate"
    rake "db:test:prepare"
  end

end
