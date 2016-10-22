module Qa::Authorities
  module MeshTools
    class MeshImporter
      def import_from_file(f)
        entries = []
        trees = []
        mesh = Qa::Authorities::MeshTools::MeshDataParser.new(f)
        mesh.each_mesh_record do |record|
          entry = []
          entry << record['UI'].first
          entry << record['MH'].first
          entry << record['MH'].first.downcase
          entry << get_synonyms(record).join('|')
          entries << entry
          next if record['MN'].nil?
          trees += record['MN'].map do |tree_number|
            [record['UI'].first,
             tree_number]
          end
        end
        Qa::SubjectMeshTerm.import([:term_id, :term, :term_lower, :synonyms], entries)
        Qa::MeshTree.import([:term_id, :tree_number], trees)
      end

      private

        def get_synonyms(record)
          first_terms(record, 'PRINT ENTRY') + first_terms(record, 'ENTRY')
        end

        def first_terms(record, field)
          return [] if record[field].nil?
          record[field].map { |s| s.split('|').first }
        end
    end
  end
end
