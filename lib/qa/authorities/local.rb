module Qa::Authorities

  class Local < Qa::Authorities::Base

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

    def search(q, sub_authority)
      Local.sub_authority(sub_authority).search(q)
    end

    def get_full_record(id, sub_authority)
      terms = Local.sub_authority(sub_authority).terms
      terms.each do |term|
        return term if term[:id] == id
      end
      return {}
    end

  end
end
