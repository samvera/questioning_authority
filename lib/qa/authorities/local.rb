require 'deprecation'
module Qa::Authorities

  class Local < Qa::Authorities::Base
    extend Deprecation

    class << self
      def sub_authority(name)
        @sub_authorities ||= {}
        raise ArgumentError, "Invalid sub-authority '#{name}'" unless Subauthority.names.include?(name)
        @sub_authorities[name] ||= Subauthority.new(name)
      end

      def sub_authorities
        Subauthority.names
      end

      def terms(sub_authority)
        sub_authority(sub_authority).terms
      end
    end

    delegate :sub_authority, to: self

    def search(q, sub_authority)
      sub_authority(sub_authority).search(q)
    end

    def full_record(id, sub_authority)
      sub_authority(sub_authority).full_record(id)
    end

    def get_full_record(id, sub_authority)
      Deprecation.warn(Local, "get_full_record is deprecated and will be removed in 0.1.0. Use full_record instead", caller)
      full_record(id, sub_authority)
    end

  end
end
