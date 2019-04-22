require 'rdf'
module Qa::Authorities
  module Discogs
    module DiscogsInstanceBuilder
      include Discogs::DiscogsUtils

      # @param [Hash] the http response from discogs
      # @return [Array] rdf statements
      def get_format_stmts(response)
        stmts = []
        # The Discogs formats array contains several types of information: the "name" field defines the type of
        # audio disc (e.g., CD vs vinyl), and the "descriptions" field can contain the playing speed, playback
        # and release information. Process the "name" field first, then the "descriptions"
        # In unusual cases, there can be multiple playing speeds. Need to distinguish among them.
        count = 1
        return stmts unless response["formats"].present?
        response["formats"].each do |format|
          stmts.concat(build_format_name_stmts(format["name"]))
          # Now process playing speed, playback channel and release info
          stmts.concat(build_format_desc_stmts(format["descriptions"], count))
          count += 1
        end
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [Hash] the http response from discogs
      # @return [Array] rdf statements
      def get_labels_stmts(response)
        stmts = []
        # Various roles are defined as provision activities, such as the record company (or label),
        # the publishing house, the recording studio, etc. These are defined separately in the Discogs
        # data, so combine them into a single array to be processed in one iteration.
        provision_activity_array = response["labels"] if response["labels"].present?
        provision_activity_array += response["companies"] if response["companies"].present?
        stmts += build_provision_activity_stmts(provision_activity_array) if provision_activity_array.present?
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [Hash] the http response from discogs
      # @return [Array] rdf statements
      def get_identifiers_stmts(response)
        stmts = []
        # The Discogs data includes identifiers such as side label codes and rights society codes.
        count = 1
        return stmts unless response["identifiers"].present?
        response["identifiers"].each do |activity|
          stmts << contruct_stmt_uri_object("Instance1", "http://id.loc.gov/ontologies/bibframe/identifiedBy", "Identifier#{count}")
          stmts << contruct_stmt_uri_object("Identifier#{count}", rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/Identifier")
          stmts << contruct_stmt_literal_object("Identifier#{count}", rdfs_label_predicate, activity["value"])
          count += 1
        end
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [Array] format descriptions discogs
      # @param [Integer] incremented on the call from get_format_stmts
      # @return [Array] rdf statements
      def build_format_desc_stmts(descs, count)
        stmts = []
        return stmts unless descs.present?
        descs.each do |desc|
          # map discogs description field to the corresponding LOC type
          df = discogs_formats[desc.gsub(/\s+/, "")]
          if df.present?
            stmts += build_format_characteristics(df, count)
          else
            stmts << contruct_stmt_literal_object("Instance1", "http://id.loc.gov/ontologies/bibframe/editionStatement", desc)
          end
        end
        stmts
      end

      # @param [Hash] discogs format descriptions "translated" to BIBFRAME terms
      # @param [Integer] incremented on the call from build_format_desc_stmts
      # @return [Array] rdf statements
      def build_format_characteristics(df, count)
        stmts = []
        case df["type"]
        when "playbackChannel"
          stmts << contruct_stmt_uri_object("Instance1", "http://id.loc.gov/ontologies/bibframe/soundCharacteristic", df["uri"])
          stmts << contruct_stmt_uri_object(df["uri"], rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/PlaybackChannel")
          stmts << contruct_stmt_literal_object(df["uri"], rdfs_label_predicate, df["label"])
        when "dimension"
          stmts << contruct_stmt_uri_object("Instance1", "http://id.loc.gov/ontologies/bibframe/dimensions", df["label"])
        when "playingSpeed"
          stmts << contruct_stmt_uri_object("Instance1", "http://id.loc.gov/ontologies/bibframe/soundCharacteristic", "PlayingSpeed#{count}")
          stmts << contruct_stmt_uri_object("PlayingSpeed#{count}", rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/PlayingSpeed")
          stmts << contruct_stmt_literal_object("PlayingSpeed#{count}", rdfs_label_predicate, df["label"])
        end
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # map discogs name field to the corresponding LOC carrier
      # @param [String] format name
      # @return [Array] rdf statements
      def build_format_name_stmts(name)
        stmts = []
        return stmts unless name.present?
        dc = discogs_formats[name.gsub(/\s+/, "")]
        if dc.present?
          stmts << contruct_stmt_uri_object("Instance1", "http://id.loc.gov/ontologies/bibframe/carrier", dc["uri"])
          stmts << contruct_stmt_uri_object(dc["uri"], rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/Carrier")
          stmts << contruct_stmt_literal_object(dc["uri"], rdfs_label_predicate, dc["label"])
          stmts.concat(build_base_materials(name))
        else
          # if it's not a carrier, it's an edition statement
          stmts << contruct_stmt_literal_object("Instance1", "http://id.loc.gov/ontologies/bibframe/editionStatement", name)
        end
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [String] format name
      # @return [Array] rdf statements
      def build_base_materials(name)
        stmts = []
        return stmts unless name == "Vinyl" || name == "Shellac"
        id = name == "Vinyl" ? "300014502" : "300014918"

        stmts << contruct_stmt_uri_object("Instance1", "http://id.loc.gov/ontologies/bibframe/baseMaterial", "http://vocab.getty.edu/aat/" + id)
        stmts << contruct_stmt_uri_object("http://vocab.getty.edu/aat/" + id, rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/BaseMaterial")
        stmts << contruct_stmt_literal_object("http://vocab.getty.edu/aat/" + id, rdfs_label_predicate, name)
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [Array] discogs roles "translated" into BIBFRAME provisional activities
      # @return [Array] rdf statements
      def build_provision_activity_stmts(activities)
        stmts = []
        # need to distinguish among different provision activities and roles
        count = 1
        activities.each do |activity|
          stmts << contruct_stmt_uri_object("Instance1", "http://id.loc.gov/ontologies/bibframe/provisionActivity", "ProvisionActivity#{count}")
          stmts << contruct_stmt_uri_object("ProvisionActivity#{count}", rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/ProvisionActivity")
          stmts << contruct_stmt_uri_object("ProvisionActivity#{count}", bf_agent_predicate, activity["name"])
          stmts << contruct_stmt_uri_object(activity["name"], rdf_type_predicate, bf_agent_type_object)
          stmts << contruct_stmt_uri_object(activity["name"], bf_role_predicate, "PA_Role#{count}")
          stmts << contruct_stmt_uri_object("PA_Role#{count}", rdf_type_predicate, bf_role_type_object)
          stmts << contruct_stmt_literal_object("PA_Role#{count}", rdfs_label_predicate, activity["entity_type_name"])
          count += 1
        end
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end
    end
  end
end
