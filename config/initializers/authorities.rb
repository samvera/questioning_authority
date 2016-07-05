Qa::Authorities::Local.load_config(File.expand_path("../../authorities.yml", __FILE__))

Qa::Authorities::Local::TableBasedAuthority.check_for_index
