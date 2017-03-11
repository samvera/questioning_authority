auth_cfg = {}
# load QA configured linked data authorities
Dir[File.join(Qa::Engine.root, 'config', 'authorities', 'linked_data', '*.json')].each do |fn|
  auth = File.basename(fn, '.json').upcase.to_sym
  json = File.read(File.expand_path(fn, __FILE__))
  cfg = JSON.parse(json).deep_symbolize_keys
  auth_cfg[auth] = cfg
end

# load app configured linked data authorities and overrides
Dir[File.join(Rails.root, 'config', 'authorities', 'linked_data', '*.json')].each do |fn|
  auth = File.basename(fn, '.json').upcase.to_sym
  json = File.read(File.expand_path(fn, __FILE__))
  cfg = JSON.parse(json).deep_symbolize_keys
  auth_cfg[auth] = cfg
end
LINKED_DATA_AUTHORITIES_CONFIG = auth_cfg.freeze
