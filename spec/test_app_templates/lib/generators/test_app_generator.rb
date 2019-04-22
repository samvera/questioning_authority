require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root Rails.root

  def update_app
    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  def run_qa_installer
    generate "qa:install"
  end

  def run_local_authority_installer
    generate "qa:local:files"
    generate "qa:local:tables"
  end

  def copy_local_authority_fixtures
    directory "../spec/fixtures/authorities", "config/authorities"
  end

  def run_discogs_installer
    generate "qa:discogs"
  end

  def run_migrations
    rake "qa:install:migrations"
    rake "db:migrate"
  end
end
