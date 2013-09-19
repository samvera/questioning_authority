module Authorities
  module MeshTools
    class MeshDataParser

      attr_accessor :file

      def initialize(file)
        @file = file
      end

      def each_mesh_record(&block)
        current_data = {}
        in_record = false
        self.file.each_line do |line|
          case line
          when /\A\*NEWRECORD/
            yield(current_data) if in_record
            in_record = true
            current_data = {}
          when /\A(?<term>[^=]+) = (?<value>.*)/
            current_data[Regexp.last_match(:term)] ||= []
            current_data[Regexp.last_match(:term)] << Regexp.last_match(:value).strip
          when /\A\n/
            yield(current_data) if in_record
            in_record = false
          end
        end
        # final time in case file did not end with a blank line
        yield(current_data) if in_record
      end

      def all_records
        result = []
        self.each_mesh_record {|rec| result << rec }
        return result
      end

      ### XXX: delete everything below?

      def self.get_synonyms(record)
        return [] if record['ENTRY'].blank?
        record['ENTRY'].map { |synonym| synonym.split('|').first }
      end

      def self.get_print_synonyms(record)
        return [] if record['PRINT ENTRY'].blank?
        record['PRINT ENTRY'].map { |synonym| synonym.split('|').first }
      end

      def self.get_description(record)
        return [] if record['MS'].blank?
        record['MS']
      end

      def self.get_tree(record)
        return [] if record['MN'].blank?
        record['MN']
      end

      def self.get_term(record)
        record['MH'].first
      end
    end
  end
end
