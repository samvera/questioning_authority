module Qa::Authorities
  module Local
    extend ActiveSupport::Autoload
    extend AuthorityWithSubAuthority
    extend Qa::Authorities::LocalSubauthority
    autoload :FileBasedAuthority
    autoload :Registry

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
