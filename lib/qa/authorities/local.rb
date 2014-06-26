module Qa::Authorities
  class Local < Base

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
      self.response = sub_authority(sub_authority).search(q)
    end

    def all(sub_authority)
      self.response = sub_authority(sub_authority).all
    end

    def full_record(id, sub_authority)
      sub_authority(sub_authority).full_record(id)
    end

  end
end
