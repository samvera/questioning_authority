class AddIndexToLocalAuthorities < ActiveRecord::Migration
  # we'd like to be able to run this, but rails quotes the functional index.
  # add_index :local_authority_entries,
  #           ['local_authority_id', 'lower(label)'],
  #           name: 'index_local_authority_entries_on_lower_label'
end
