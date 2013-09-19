module Authorities
  module MeshTools
    class MeshImporter
      def import_from_file(f)
        entries = []
        trees = []
        mesh = MeshDataParser.new(f)
        mesh.each_mesh_record do |record|
          entry = []
          entry << record['UI'].first
          entry << record['MH'].first
          entry << record['MH'].first.downcase
          entry << get_synonyms(record).join('|')
          entries << entry
          unless record['MN'].nil?
            trees += record['MN'].map do |tree_number|
              [record['UI'].first,
               tree_number]
            end
          end
        end
        SubjectMeshTerm.import([:term_id, :term, :term_lower, :synonyms], entries)
        MeshTree.import([:term_id, :tree_number], trees)
      end

      private

      def get_synonyms(record)
        first_terms(record, 'PRINT ENTRY') + first_terms(record, 'ENTRY')
      end

      def first_terms(record, field)
        return [] if record[field].nil?
        record[field].map { |s| s.split('|').first }
      end

      def tree_number_to_term_list
      end
    end
  end
end
