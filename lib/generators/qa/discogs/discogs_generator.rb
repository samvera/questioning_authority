class Qa::DiscogsGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc """
    This generator makes the following change to your application:
    1. Adds the Discogs authority configuration
       """
  def copy_discogs_configs
    copy_file "config/discogs-formats.yml", "config/discogs-formats.yml"
    copy_file "config/discogs-genres.yml", "config/discogs-genres.yml"
  end
end
