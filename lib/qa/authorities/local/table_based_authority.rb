module Qa::Authorities
  class Local::TableBasedAuthority < Base
    def self.check_for_index
      conn = ActiveRecord::Base.connection
      if conn.table_exists?('local_authority_entries') && !conn.indexes('local_authority_entries').find { |i| i.name == 'index_local_authority_entries_on_lower_label' }
        Rails.logger.error "You've installed local authority tables, but you haven't indexed the label.  Rails doesn't support functional indexes in migrations, so you'll have to add this manually:\n" \
          "CREATE INDEX \"index_qa_local_authority_entries_on_lower_label\" ON \"qa_local_authority_entries\" (local_authority_id, lower(label))\n" \
          "   OR on Sqlite: \n" \
          "CREATE INDEX \"index_qa_local_authority_entries_on_lower_label\" ON \"qa_local_authority_entries\" (local_authority_id, label collate nocase)\n" \
      end
    end

    attr_reader :subauthority

    def initialize(subauthority)
      @subauthority = subauthority
    end

    def search(q)
      return [] if q.blank?
      output_set(base_relation.where('lower(label) like ?', "#{q.downcase}%").limit(25))
    end

    def all
      output_set(base_relation.limit(1000))
    end

    def find(uri)
      record = base_relation.find_by(uri: uri)
      return unless record
      output(record)
    end

    private

      def base_relation
        Qa::LocalAuthorityEntry.where(local_authority: local_authority)
      end

      def output_set(set)
        set.map { |item| output(item) }
      end

      def output(item)
        { id: item[:uri], label: item[:label] }.with_indifferent_access
      end

      def local_authority
        Qa::LocalAuthority.find_by_name(subauthority)
      end

  end
end
