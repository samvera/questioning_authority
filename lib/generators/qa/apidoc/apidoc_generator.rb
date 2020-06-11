# frozen_string_literal: true
class Qa::ApidocGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc """
This generator makes the following changes to your application:
1. Add swagger-docs gem and bundle install
2. Add swagger documentation for the QA linked data API

"""

  def add_to_gemfile
    gem 'swagger-docs'

    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  def copy_api_docs
    directory "public/qa/apidoc", recursive: false
  end
end
