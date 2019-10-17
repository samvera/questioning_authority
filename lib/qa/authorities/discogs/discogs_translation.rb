require 'rdf'
module Qa::Authorities
  module Discogs
    module DiscogsTranslation
      include Discogs::DiscogsUtils
      include Discogs::DiscogsWorksBuilder
      include Discogs::DiscogsInstanceBuilder

      # Returns modified Discogs data in json-ld format. The data is first structured as RDF
      # statements that use the BIBFRAME ontology. Where applicable, Discogs terms are mapped
      # to the URIs of corresponding objects in the Library of Congress vocabulary.
      # @param [Hash] the http response from discogs
      # @param [String] the subauthority
      # @return [Array, String] requested RDF serialzation (supports: jsonld Array, n3 String, n-triples String)
      def build_graph(response, subauthority = "", format: :jsonld)
        graph = RDF::Graph.new

        rdf_statements = compile_rdf_statements(response, subauthority)
        graph.insert_statements(rdf_statements)

        graph.dump(format, standard_prefixes: true)
      end

      # @param [Hash] the http response from discogs
      # @param [String] the subauthority
      # @return [Array] rdf statements
      def compile_rdf_statements(response, subauthority)
        complete_rdf_stmts = []
        # The necessary statements depend on the subauthority. If the subauthority is master,
        # all we need is a work and not an instance. If there's no subauthority, we can determine
        # if the discogs record is a master because it will have a main_release field.
        if master_only(response, subauthority)
          self.work_uri = response["uri"].present? ? response["uri"] : response["resource_url"]
          complete_rdf_stmts.concat(build_master_statements(response))
        else
          # If the subauthority is "release," we need to define an instance as well as a
          # work. If the discogs record has a master_id, fetch that and use the results to
          # build the statements for the work.
          master_resp = response["master_id"].present? ? json("https://api.discogs.com/masters/#{response['master_id']}") : response
          complete_rdf_stmts.concat(build_master_statements(master_resp))
          # Now do the statements for the release/instance.
          self.instance_uri = response["uri"].present? ? response["uri"] : response["resource_url"]
          complete_rdf_stmts.concat(build_instance_statements(response))
        end
      end

      # @param [Hash] the http response from discogs
      # @param [String] the subauthority
      # @return [Boolean] returns true if the subauthority is "master" or the response contains a master
      def master_only(response, subauthority)
        return true if subauthority == "master"
        return true if response["main_release"].present?
        false
      end

      # @param [Hash] the http response from discogs
      # @return [Array] rdf statements
      def build_master_statements(response)
        # get the statements that define the primary work
        master_stmts = get_primary_work_definition(response)
        master_stmts.concat(get_primary_artists_stmts(response))
        master_stmts.concat(get_extra_artists_stmts(response))
        master_stmts.concat(get_genres_stmts(response))
        # get the statements that define the secondary works by converting the tracklist
        master_stmts.concat(get_tracklist_artists_stmts(response))
      end

      # @param [Hash] the http response from discogs
      # @return [Array] rdf statements
      def build_instance_statements(response)
        # get the statements that define the instance
        instance_stmts = get_primary_instance_definition(response)
        instance_stmts.concat(get_format_stmts(response))
        instance_stmts.concat(get_labels_stmts(response))
        instance_stmts.concat(get_identifiers_stmts(response))
      end

      # @param [Hash] the http response from discogs
      # @return [Array] rdf statements
      def get_primary_work_definition(response)
        stmts = []
        stmts << contruct_stmt_uri_object(work_uri, rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/Work")
        stmts << contruct_stmt_uri_object(work_uri, "http://id.loc.gov/ontologies/bibframe/title", "titlen1")
        stmts << contruct_stmt_literal_object("titlen1", bf_main_title_predicate, response["title"])
        stmts << contruct_stmt_uri_object("titlen1", rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/Title")
        stmts << contruct_stmt_uri_object(work_uri, rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/Audio")
        stmts << contruct_stmt_literal_object(work_uri, "http://id.loc.gov/ontologies/bibframe/originDate", response["year"].to_s) if response["year"].present?
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [Hash] the http response from discogs
      # @return [Array] rdf statements
      def get_primary_instance_definition(response)
        stmts = []
        stmts << contruct_stmt_uri_object(instance_uri, "http://id.loc.gov/ontologies/bibframe/instanceOf", work_uri)
        stmts << contruct_stmt_uri_object(instance_uri, rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/Instance")
        stmts << contruct_stmt_uri_object(instance_uri, "http://id.loc.gov/ontologies/bibframe/title", "titlen2")
        stmts << contruct_stmt_literal_object("titlen2", bf_main_title_predicate, response["title"])
        stmts << contruct_stmt_uri_object("titlen2", rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/Title")
        stmts << contruct_stmt_uri_object(instance_uri, "http://id.loc.gov/ontologies/bibframe/identifiedBy", "widn1")
        stmts << contruct_stmt_uri_object("widn1", rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/Identifier")
        stmts << contruct_stmt_literal_object("widn1", "http://www.w3.org/1999/02/22-rdf-syntax-ns#value", response["id"])
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [Hash] the http response from discogs
      # @return [Array] rdf statements
      def get_primary_artists_stmts(response)
        stmts = []
        # can have multiple artists as primary contributors to the work; need to distinguish among them
        count = 1
        # for secondary contributors to the work
        if response["artists"].present?
          response["artists"].each do |artist|
            # we need the primary artists later when we loop through the track list, so build this array
            primary_artists << artist

            stmts << contruct_stmt_uri_object(work_uri, "http://id.loc.gov/ontologies/bibframe/contribution", "contrbn#{count}")
            stmts << contruct_stmt_uri_object("contrbn#{count}", rdf_type_predicate, "http://id.loc.gov/ontologies/bflc/PrimaryContribution")
            stmts << contruct_stmt_uri_object("contrbn#{count}", bf_agent_predicate, "agentn#{count}")
            stmts << contruct_stmt_uri_object("agentn#{count}", rdf_type_predicate, bf_agent_type_object)
            stmts << contruct_stmt_literal_object("agentn#{count}", rdfs_label_predicate, artist["name"])
            count += 1
          end
        end
        stmts
      end
    end
  end
end
