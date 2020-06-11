# frozen_string_literal: true
require 'rdf'
module Qa::Authorities
  module Discogs
    module DiscogsUtils
      DISCOGS_GENRE_MAPPING = YAML.load_file(Rails.root.join("config", "discogs-genres.yml"))
      DISCOGS_FORMATS_MAPPING = YAML.load_file(Rails.root.join("config", "discogs-formats.yml"))

      # Constructs an RDF statement where the subject, predicate and object are all URIs
      # @param [String] either a string used to create a unique URI or an LOC uri in string format
      # @param [String] or [Class] either a BIBFRAME property uri in string format or an RDF::URI
      # @param [String] or [Class] strings can be a label or BIBFRAME class uri; class is always RDF::URI
      # @return [Class] RDF::Statement with either a uri or a bnode as the object
      def contruct_stmt_uri_object(subject, predicate, object)
        s = subject.include?("http") ? RDF::URI.new(subject) : subject.to_sym
        o = object.to_s.include?("http") ? RDF::URI.new(object) : object.to_sym
        RDF::Statement(s, RDF::URI(predicate), o)
      end

      # Constructs an RDF statement where the subject and predicate are URIs and the object is a literal
      # @param [String] either a string used to create a unique URI or an LOC uri in string format
      # @param [String] or [Class] either a BIBFRAME property uri in string format or an RDF::URI
      # @param [String] or [Class] strings can be a label or BIBFRAME class uri; class is always RDF::URI
      # @return [Class] RDF::Statement with a literal as the object
      def contruct_stmt_literal_object(subject, predicate, object)
        s = subject.include?("http") ? RDF::URI.new(subject) : subject.to_sym
        RDF::Statement(s, RDF::URI(predicate), RDF::Literal.new(object))
      end

      # frequently used predicates and objects
      def rdf_type_predicate
        RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type")
      end

      def rdfs_label_predicate
        RDF::URI("http://www.w3.org/2000/01/rdf-schema#label")
      end

      def bf_main_title_predicate
        RDF::URI("http://id.loc.gov/ontologies/bibframe/mainTitle")
      end

      def bf_agent_predicate
        RDF::URI("http://id.loc.gov/ontologies/bibframe/agent")
      end

      def bf_agent_type_object
        "http://id.loc.gov/ontologies/bibframe/Agent"
      end

      def bf_role_predicate
        RDF::URI("http://id.loc.gov/ontologies/bibframe/role")
      end

      def bf_role_type_object
        "http://id.loc.gov/ontologies/bibframe/Role"
      end

      def format(tc)
        return 'json' unless tc.params.key?('format')
        return 'json' if tc.params['format'].blank?
        tc.params['format']
      end

      def jsonld?(tc)
        format(tc).casecmp?('jsonld')
      end

      def n3?(tc)
        format(tc).casecmp?('n3')
      end

      def ntriples?(tc)
        format(tc).casecmp?('ntriples')
      end

      def graph_format?(tc)
        jsonld?(tc) || n3?(tc) || ntriples?(tc)
      end

      def discogs_genres
        DISCOGS_GENRE_MAPPING
      end

      def discogs_formats
        DISCOGS_FORMATS_MAPPING
      end

      # @param json results
      # @param json results
      # @return [String] status information
      def check_for_msg_response(release_resp, master_resp)
        if release_resp.key?("message") && master_resp.key?("message")
          "no responses"
        elsif !release_resp.key?("message") && !master_resp.key?("message")
          "two responses"
        else
          "mixed"
        end
      end

      # both the work and the instance require a statement for the release year
      # @param [Hash] the http response from discogs
      # @return [Array] rdf statements
      def build_year_statements(response)
        year_stmts = []
        year_stmts << contruct_stmt_uri_object(instance_uri, "http://id.loc.gov/ontologies/bibframe/provisionActivity", "daten1")
        year_stmts << contruct_stmt_uri_object("daten1", rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/Publication")
        year_stmts << contruct_stmt_literal_object("daten1", RDF::URI("http://id.loc.gov/ontologies/bibframe/date"), response["released"].to_s)
        year_stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [Hash] the extraartists defined at the release level, not the track level
      # @param [Integer] gives the role a unique uri
      # @param [String] the entity type name
      # @return [Array] rdf statements
      def build_role_stmts(subject_node, role_node, label)
        stmts = []
        stmts << contruct_stmt_uri_object(subject_node, bf_role_predicate, role_node)
        stmts << contruct_stmt_uri_object(role_node, rdf_type_predicate, bf_role_type_object)
        stmts << contruct_stmt_literal_object(role_node, rdfs_label_predicate, label)
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [String] the playing speed in string format
      # @param [Integer] gives the playing speed a unique uri
      # @return [Array] rdf statements
      def build_playing_speed_stmts(label, count)
        stmts = []
        stmts << contruct_stmt_uri_object(instance_uri, "http://id.loc.gov/ontologies/bibframe/soundCharacteristic", "speed#{count}")
        stmts << contruct_stmt_uri_object("speed#{count}", rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/PlayingSpeed")
        stmts << contruct_stmt_literal_object("speed#{count}", rdfs_label_predicate, label)
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end
    end
  end
end
