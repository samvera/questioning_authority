require 'rake'
require 'fileutils'
require 'logger'

namespace :mesh do
  def timed_action(action_name, &block)
    start_time = Time.now
    logger.info("\t ############ Starting #{action_name} at #{start_time} ")
    yield
    end_time = Time.now
    time_taken = end_time - start_time
    logger.info("\t ############ Complete #{action_name} at #{end_time}, Duration #{time_taken.inspect} ")
  end

  desc "Import MeSH terms from the file $MESH_FILE, it will update any terms which are already in the database"
  task :import => :environment do
  end

  desc "Delete all mesh terms from the database---not implemented"
  task :clear do
    puts "Not implemented"
  end

  #
  # old code
  #

  namespace :import do
    def mesh_files
      files=[]
      files<< File.expand_path("#{Rails.root}/mesh-d2013.txt")
    end
    desc "Import Mesh Subjects from text file mesh-d2013.txt"
    task :mesh_subjects => :environment do
      timed_action "harvest" do
        LocalAuthority.harvest_more_mesh_ascii("mesh_subject_harvest",mesh_files)
      end
    end
    task :one_time_mesh_print_entry_import => :environment do
      timed_action "harvest print entry" do
        LocalAuthority.harvest_more_mesh_print_synonyms("mesh_subject_harvest",mesh_files)
      end
    end

    desc "Resolve Mesh Tree Structure"
    task :eval_mesh_trees  => :environment do
      timed_action "eval tree" do
        MeshTreeStructure.classify_all_trees
      end
    end
  end
end
