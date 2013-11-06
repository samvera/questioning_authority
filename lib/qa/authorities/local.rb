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
      terms = Local.sub_authority(sub_authority).terms
      r = q.blank? ? terms : terms.select { |term| term[:term].downcase.start_with?(q.downcase) }
      r.map do |res|
        { :id => res[:id], :label => res[:term] }.with_indifferent_access
      end
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
