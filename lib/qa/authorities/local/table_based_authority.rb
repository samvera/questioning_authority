module Qa::Authorities
  class Local::TableBasedAuthority < Base
    class_attribute :table_name, :table_index
    self.table_name = "qa_local_authority_entries"
    self.table_index = "index_qa_local_authority_entries_on_lower_label"

    class << self
      def check_for_index
        @checked_for_index ||= begin
          conn = ActiveRecord::Base.connection
          if table_or_view_exists? && !conn.indexes(table_name).find { |i| i.name == table_index }
            Rails.logger.error "You've installed local authority tables, but you haven't indexed the label.  Rails doesn't support functional indexes in migrations, so you'll have to add this manually:\n" \
              "CREATE INDEX \"#{table_index}\" ON \"#{table_name}\" (local_authority_id, lower(label))\n" \
              "   OR on Sqlite: \n" \
              "CREATE INDEX \"#{table_index}\" ON \"#{table_name}\" (local_authority_id, label collate nocase)\n" \
              "   OR for MySQL use the MSQLTableBasedAuthority instead, since mysql does not support functional indexes."
          end
        end
      end

      private

        def table_or_view_exists?
          conn = ActiveRecord::Base.connection
          if conn.respond_to?(:data_source_exists?)
            conn.data_source_exists?(table_name)
          else
            conn.table_exists?(table_name)
          end
        end
    end

    attr_reader :subauthority

    def initialize(subauthority)
      self.class.check_for_index
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
