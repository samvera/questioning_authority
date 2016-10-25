module Qa::Authorities
  module MeshTools
    class MeshDataParser
      attr_accessor :file

      def initialize(file)
        @file = file
      end

      def each_mesh_record
        current_data = {}
        in_record = false
        file.each_line do |line|
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
        each_mesh_record { |rec| result << rec }
        result
      end
    end
  end
end
