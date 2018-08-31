module Qa
  module Authorities
    module Local
      class MysqlTableBasedAuthority < Local::TableBasedAuthority
        self.table_index = "index_qa_local_authority_entries_on_lower_label_and_authority"

        def self.check_for_index
          if table_or_view_exists? && index_name_exists? # rubocop:disable Style/GuardClause
            Rails.logger.error "You've installed mysql local authority tables, but you haven't indexed the lower label. "
            "Rails doesn't support functional indexes in migrations, so we tried to execute it for you but something went wrong...\n" \
            "Make sure your table has a lower_label column, which is virtually created, and that the column is indexed." \
            " ALTER TABLE #{table_name} ADD lower_label VARCHAR(256) GENERATED ALWAYS AS (lower(label)) VIRTUAL" \
            " CREATE INDEX #{table_index} ON #{table_name} (local_authority_id, lower_label)"
          end
        end

        def search(q)
          return [] if q.blank?
          output_set(base_relation.where('lower_label like ?', "#{q.downcase}%").limit(25))
        end

        def self.index_name_exists?
          conn = ActiveRecord::Base.connection
          if ActiveRecord::VERSION::MAJOR >= 5 && ActiveRecord::VERSION::MINOR >= 1
            conn.index_name_exists?(table_name, table_index).blank?
          else
            conn.index_name_exists?(table_name, table_index, :default).blank?
          end
        end
        private_class_method :index_name_exists?
      end
    end
  end
end
