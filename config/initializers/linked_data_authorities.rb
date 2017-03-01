LINKED_DATA_AUTHORITIES_CONFIG = {}

# load QA configured linked data authorities
Dir[File.join(Qa::Engine.root, 'config', 'authorities', 'linked_data', '*.json')].each do |fn|
  auth = File.basename(fn, '.json').upcase.to_sym
  json = File.read(File.expand_path(fn, __FILE__))
  cfg = JSON.parse(json).deep_symbolize_keys
  LINKED_DATA_AUTHORITIES_CONFIG[auth] = cfg
end

# load app configured linked data authorities and overrides
Dir[File.join(Rails.root, 'config', 'authorities', 'linked_data', '*.json')].each do |fn|
  auth = File.basename(fn, '.json').upcase.to_sym
  json = File.read(File.expand_path(fn, __FILE__))
  cfg = JSON.parse(json).deep_symbolize_keys
  unless LINKED_DATA_AUTHORITIES_CONFIG.key?(auth)
    LINKED_DATA_AUTHORITIES_CONFIG[auth] = cfg
    next
  end
  Qa::Authorities::LinkedData::Config.merge(LINKED_DATA_AUTHORITIES_CONFIG[auth], cfg)
end
