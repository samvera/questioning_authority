Rails.application.reloader.to_prepare do
  Qa::LinkedData::AuthorityService.load_authorities
end
