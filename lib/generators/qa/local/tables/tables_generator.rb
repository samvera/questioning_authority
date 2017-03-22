require 'rails/generators/active_record/migration'
module Qa::Local
  class TablesGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    include ActiveRecord::Generators::Migration

    def migrations
      if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter) && ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
        message = "Use the mysql table based generator if you are using mysql 'rails generate qa:local:tables:mysql'"
        say_status("error", message, :red)
        return 0
      end
      generate "model qa/local_authority name:string:uniq"
      generate "model qa/local_authority_entry local_authority:references label:string uri:string:uniq"
      migration_file = Dir.entries(File.join(destination_root, 'db/migrate/'))
                          .reject { |name| !name.include?('create_qa_local_authority_entries') }.first
      migration_file = File.join('db/migrate', migration_file)
      gsub_file migration_file,
                /t\.references :local_authority.*/,
                't.references :local_authority, foreign_key: { to_table: :qa_local_authorities }, index: true'
      message = "Rails doesn't support functional indexes in migrations, so you'll have to add this manually:\n" \
                "CREATE INDEX \"index_qa_local_authority_entries_on_lower_label\" ON \"qa_local_authority_entries\" (local_authority_id, lower(label))\n" \
                "   OR on Sqlite: \n" \
                "CREATE INDEX \"index_qa_local_authority_entries_on_lower_label\" ON \"qa_local_authority_entries\" (local_authority_id, label collate nocase)\n"
      say_status("info", message, :yellow)
    end
  end
end
