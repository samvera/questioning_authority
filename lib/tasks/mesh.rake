require 'rake'
require 'fileutils'
require 'logger'

namespace :mesh do
  def timed_action(action_name, &block)
    start_time = Time.now
    puts "\t ############ Starting #{action_name} at #{start_time}"
    yield
    end_time = Time.now
    time_taken = end_time - start_time
    puts "\t ############ Complete #{action_name} at #{end_time}, Duration #{time_taken.inspect}"
  end

  desc "Import MeSH terms from the file $MESH_FILE, it will update any terms which are already in the database"
  task :import => :environment do
    fname = ENV['MESH_FILE']
    if fname.nil?
      puts "Need to set $MESH_FILE with path to file to ingest"
      return
    end
    timed_action "Importing #{fname}" do
      m = Authorities::MeshTools::MeshImporter.new
      File.open(fname) do |f|
        m.import_from_file(f)
      end
    end
  end

  desc "Delete all mesh terms from the database---not implemented"
  task :clear do
    puts "Not implemented"
  end

end
