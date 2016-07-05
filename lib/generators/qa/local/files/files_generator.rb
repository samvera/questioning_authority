module Qa::Local
  class FilesGenerator < Rails::Generators::Base
    source_root File.expand_path('../../templates', __FILE__)

    def copy_local_authority_configs
      copy_file "config/authorities.yml", "config/authorities.yml"
      directory "config/authorities"
    end
  end
end
