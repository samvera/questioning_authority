module Qa::Authorities
  module Local
    extend ActiveSupport::Autoload
    extend AuthorityWithSubAuthority
    autoload :FileBasedAuthority
    autoload :Registry
    autoload :TableBasedAuthority
    autoload :MysqlTableBasedAuthority

    class << self
      attr_reader :config

      def load_config(file)
        @config = YAML.load_file(file)
      end

      # Path to sub-authority files is either the full path to a directory or
      # the path to a directory relative to the Rails application
      def subauthorities_path
        if config[:local_path].starts_with?(File::Separator)
          config[:local_path]
        else
          File.join(Rails.root, config[:local_path])
        end
      end

      # Local sub-authorities are any YAML files in the subauthorities_path
      def names
        unless Dir.exist? subauthorities_path
          raise Qa::ConfigDirectoryNotFound, "There's no directory at #{subauthorities_path}. You must create it in order to use local authorities"
        end
        Dir.entries(subauthorities_path).map { |f| File.basename(f, ".yml") if f =~ /yml$/ }.compact
      end

      def subauthority_for(subauthority)
        validate_subauthority!(subauthority)
        registry.instance_for(subauthority)
      end

      def registry
        @registry ||= begin
          Registry.new do |reg|
            register_defaults(reg)
          end
        end
      end

      ##
      # Lookup and add the subauthority to the registry. This should only be used for sub-authorities, not stand-alone authorities such as Tgnlang, MESH, etc.
      # @param subauthority [String] a string representation of the subauthority (e.g. "language")
      # @param class_name [String] a string representation of an authority class (e.g. "Qa::Authorities::Local::MysqlTableBasedAuthority")
      def register_subauthority(subauthority, class_name)
        registry.add(subauthority, class_name)
      end

      def subauthorities
        registry.keys
      end

      private

        def register_defaults(reg)
          names.each do |name|
            reg.add(name, 'Qa::Authorities::Local::FileBasedAuthority')
          end
        end
    end
  end
end
