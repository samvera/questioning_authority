require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root File.expand_path("../../../../support", __FILE__)

  def inject_routes
    insert_into_file "config/routes.rb", :after => ".draw do" do
      %{

  mount Qa::Engine => '/qa'

      }
    end
  end

  def copy_configs
    copy_file "../../config/oclcts-authorities.yml", "config/oclcts-authorities.yml"
  end

end