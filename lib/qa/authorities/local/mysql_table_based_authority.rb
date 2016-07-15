module Qa
  module Authorities
    module Local
      #
      class MysqlTableBasedAuthority < Local::TableBasedAuthority
        def self.check_for_index
          conn = ActiveRecord::Base.connection
          if conn.table_exists?('qa_local_authority_entries') && conn.index_name_exists?(:qa_local_authority_entries, 'index_qa_local_authority_entries_on_lower_label_and_authority', :default).blank?
            Rails.logger.error "You've installed mysql local authority tables, but you haven't indexed the lower label.  Rails doesn't support functional indexes in migrations, so we tried to execute it for you but something went wrong...\n" \
              'Make sure your table has a lower_label column which is virtuall created and that column is indexed' \
              ' ALTER TABLE qa_local_authority_entries ADD lower_label VARCHAR(256) GENERATED ALWAYS AS (lower(label)) VIRTUAL' \
              ' CREATE INDEX index_qa_local_authority_entries_on_lower_label_and_authority ON qa_local_authority_entries (local_authority_id, lower_label)'
          end
        end

        def search(q)
          return [] if q.blank?
          output_set(base_relation.where('lower_label like ?', "#{q.downcase}%").limit(25))
        end
      end
    end
  end
end
