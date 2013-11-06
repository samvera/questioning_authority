require 'benchmark'

namespace :mesh do
  desc "Import MeSH terms from the file $MESH_FILE, it will update any terms which are already in the database"
  task :import => :environment do
    fname = ENV['MESH_FILE']
    if fname.nil?
      puts "Need to set $MESH_FILE with path to file to ingest"
      next  # transfers control out of this block
    end
    Benchmark.bm(30) do |bm|
      bm.report("Importing #{fname}") do
        m = Qa::Authorities::MeshTools::MeshImporter.new
        File.open(fname) do |f|
          m.import_from_file(f)
        end
      end
    end
  end

  desc "Delete all mesh terms from the database---not implemented"
  task :clear do
    puts "Not implemented"
  end

end
