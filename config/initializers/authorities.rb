Rails.application.reloader.to_prepare do
  Qa::Authorities::Local.load_config(File.expand_path("../../authorities.yml", __FILE__))
end
