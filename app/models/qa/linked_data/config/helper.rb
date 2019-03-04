# Provide helper method for common processing of configurations.
module Qa
  module LinkedData
    module Config
      class Helper
        # Fetch a value from a hash map
        def self.fetch(map, key, default)
          map.fetch(key, default)
        end

        # Fetch a boolean value from a hash map throwing an exception if the value is not boolean
        def self.fetch_boolean(map, key, default)
          value = map.fetch(key, default)
          raise Qa::InvalidConfiguration, "#{key} must be true or false" unless value == true || value == false
          value
        end

        # Fetch a value from a hash map throwing an exception if the value is blank
        def self.fetch_required(map, key, default)
          value = map.fetch(key, default)
          raise Qa::InvalidConfiguration, "#{key} is required" unless value
          value
        end

        # Fetch a value from a hash map throwing an exception if the value is blank
        def self.fetch_symbol(map, key, default)
          value = map.fetch(key, default)
          return value unless value.respond_to? :to_sym
          value.to_sym
        end
      end
    end
  end
end
