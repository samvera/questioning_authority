LINKED_DATA_AUTHORITIES_CONFIG = {}

# load QA configured linked data authorities
Dir[File.join(Qa::Engine.root, 'config', 'authorities', 'linked_data', '*.yml')].each do |fn|
  auth = File.basename(fn, '.yml').upcase.to_sym
  cfg = YAML.load_file(File.expand_path(fn, __FILE__))
  LINKED_DATA_AUTHORITIES_CONFIG[auth] = cfg
end

# load app configured linked data authorities and overrides
Dir[File.join(Rails.root, 'config', 'authorities', 'linked_data', '*.yml')].each do |fn|
  auth = File.basename(fn, '.yml').upcase.to_sym
  cfg = YAML.load_file(File.expand_path(fn, __FILE__))
  unless LINKED_DATA_AUTHORITIES_CONFIG.key?(auth)
    LINKED_DATA_AUTHORITIES_CONFIG[auth] = cfg
    next
  end
  LINKED_DATA_AUTHORITIES_CONFIG[auth].merge! cfg
end
