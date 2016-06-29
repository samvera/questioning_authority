module Qa::Authorities
  module Local
    extend ActiveSupport::Autoload
    extend AuthorityWithSubAuthority
    autoload :FileBasedAuthority
    autoload :Registry

    def self.config
      @config
    end

    def self.load_config(file)
      @config = YAML.load_file(file)
    end

    # Path to sub-authority files is either the full path to a directory or
    # the path to a directory relative to the Rails application
    def self.subauthorities_path
      if config[:local_path].starts_with?(File::Separator)
        config[:local_path]
      else
        File.join(Rails.root, config[:local_path])
      end
    end

    # Local sub-authorities are any YAML files in the subauthorities_path
    def self.names
      unless Dir.exists? subauthorities_path
        raise Qa::ConfigDirectoryNotFound, "There's no directory at #{subauthorities_path}. You must create it in order to use local authorities"
      end
      Dir.entries(subauthorities_path).map { |f| File.basename(f, ".yml") if f.match(/yml$/) }.compact
    end

    def self.subauthority_for(subauthority)
      validate_subauthority!(subauthority)
      registry.instance_for(subauthority)
    end

    def self.registry
      @registry ||= begin
        Registry.new do |reg|
          register_defaults(reg)
        end
      end
    end

    def self.register_subauthority(subauthority, class_name)
      registry.add(subauthority, class_name)
    end

    def self.subauthorities
      registry.keys
    end

    private
      def self.register_defaults(reg)
        names.each do |name|
          reg.add(name, 'Qa::Authorities::Local::FileBasedAuthority')
        end
      end
  end
end
