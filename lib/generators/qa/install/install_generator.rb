class Qa::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc """
    This generator makes the following changes to your application:
    1. Set up mount of Qa in routes
    2. Add qa initializer to config/initializers
    3. Add oclcts authority configuration
         """

  def inject_routes
    insert_into_file "config/routes.rb", after: ".draw do" do
      %(\n  mount Qa::Engine => '/qa'\n)
    end
  end

  def create_initializer_config_file
    copy_file 'config/initializers/qa.rb'
  end

  def copy_oclcts_configs
    copy_file "config/oclcts-authorities.yml", "config/oclcts-authorities.yml"
  end
end
