require 'rdf'
module Qa::Authorities
  module Discogs
    module DiscogsWorksBuilder # rubocop:disable Metrics/ModuleLength
      include Discogs::DiscogsUtils

      # @param [Hash] the http response from discogs
      # @return [Array] rdf statements
      def get_extra_artists_stmts(response)
        stmts = []
        # can have multiple artists as primary contributors to the work; need to distinguish among them
        count = 1
        return stmts unless response["extraartists"].present?
        response["extraartists"].each do |artist|
          stmts << contruct_stmt_uri_object("Work1", "http://id.loc.gov/ontologies/bibframe/contribution", "Work1SecondaryContribution#{count}")
          stmts << contruct_stmt_uri_object("Work1SecondaryContribution#{count}", rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/Contribution")
          stmts << contruct_stmt_uri_object("Work1SecondaryContribution#{count}", bf_agent_predicate, artist["name"])
          stmts << contruct_stmt_uri_object(artist["name"], rdf_type_predicate, bf_agent_type_object)
          stmts += build_artist_role_stmts(artist, count)
          count += 1
        end
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [Hash] the extraartists defined at the release level, not the track level
      # @param [Integer] gives the role a unique uri
      # @return [Array] rdf statements
      def build_artist_role_stmts(artist, count)
        stmts = []
        stmts << contruct_stmt_uri_object(artist["name"], bf_role_predicate, "Work1SecondaryContributor_Role#{count}")
        stmts << contruct_stmt_uri_object("Work1SecondaryContributor_Role#{count}", rdf_type_predicate, bf_role_type_object)
        stmts << contruct_stmt_literal_object("Work1SecondaryContributor_Role#{count}", rdfs_label_predicate, artist["role"])
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [Hash] the http response from discogs
      # @return [Array] rdf statements
      def get_genres_stmts(response)
        stmts = []
        all_genres = []
        all_genres += response["genres"] if response["genres"].present?
        all_genres += response["styles"] if response["styles"].present?
        return stmts unless all_genres.any?
        all_genres.each do |genre|
          stmts.concat(build_genres(genre))
        end
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # map discogs genre to LOC genreForm
      # @param [String] the name of a discogs style or genre
      # @return [Array] rdf statements
      def build_genres(genre)
        stmts = []
        dg = discogs_genres[genre.gsub(/\s+/, "")]
        if dg.present?
          stmts << contruct_stmt_uri_object("Work1", "http://id.loc.gov/ontologies/bibframe/genreForm", dg["uri"])
          stmts << contruct_stmt_uri_object(dg["uri"], rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/GenreForm")
          stmts << contruct_stmt_literal_object(dg["uri"], rdfs_label_predicate, dg["label"])
        end
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [String] the uri of the genreForm
      # @param [String] the genreForm label
      # @return [Array] rdf statements
      def build_genres_and_styles(uri, dg_label)
        stmts = []
        stmts << contruct_stmt_uri_object("Work1", "http://id.loc.gov/ontologies/bibframe/genreForm", uri)
        stmts << contruct_stmt_uri_object(uri, rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/GenreForm")
        stmts << contruct_stmt_literal_object(uri, rdfs_label_predicate, dg_label)
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [Hash] the http response from discogs
      # @return [Array] rdf statements
      def get_tracklist_artists_stmts(response)
        stmts = []
        # individual tracks become secondary works; need to distinguish among them
        w_count = 2
        return stmts unless response["tracklist"].present?
        response["tracklist"].each do |track|
          stmts.concat(build_secondary_works(track, w_count))
          # If the Discogs data includes the primary artists for each track, use those. If not,
          # use the primary artists that are associated with the main work
          artist_array = build_artist_array(track["artists"])
          stmts.concat(build_track_artists(artist_array, w_count))
          stmts.concat(build_track_extraartists(track["extraartists"], w_count)) if track["extraartists"].present?
          w_count += 1
        end
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # If the tracklist does not include the primary artists, use the ones defined at the master or release level
      # @param [Array] artists from discogs
      # @return [Array] either the tracklist "artists" or the primary artists
      def build_artist_array(artists)
        artists.present? ? artists : primary_artists
      end

      # @param [Hash] discogs artists associated with the main work (master or release)
      # @param [Integer] used to give unique URIS for works
      # @return [Array] rdf statements
      def build_secondary_works(track, w_count)
        stmts = []
        stmts << contruct_stmt_uri_object("Work1", "http://id.loc.gov/ontologies/bibframe/hasPart", "Work#{w_count}")
        stmts << contruct_stmt_uri_object("Work#{w_count}", rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/Work")
        stmts << contruct_stmt_uri_object("Work#{w_count}", rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/Audio")
        stmts << contruct_stmt_uri_object("Work#{w_count}", "http://id.loc.gov/ontologies/bibframe/title", "Work#{w_count}Title")
        stmts << contruct_stmt_uri_object("Work#{w_count}Title", rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/Title")
        stmts << contruct_stmt_literal_object("Work#{w_count}Title", bf_main_title_predicate, track["title"])
        stmts << contruct_stmt_literal_object("Work#{w_count}", "http://id.loc.gov/ontologies/bibframe/duration", track["duration"]) if track["duration"].present?
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [Array] discogs artists associated with the main work (master or release)
      # @param [Integer] used to give unique URIS for works and primary contributions
      # @return [Array] rdf statements
      def build_track_artists(artists, w_count)
        stmts = []
        count = 1
        artists.each do |artist|
          stmts << contruct_stmt_uri_object("Work#{w_count}", "http://id.loc.gov/ontologies/bibframe/contribution", "Work#{w_count}PrimaryContribution#{count}")
          stmts << contruct_stmt_uri_object("Work#{w_count}PrimaryContribution#{count}", rdf_type_predicate, "http://id.loc.gov/ontologies/bflc/PrimaryContribution")
          stmts << contruct_stmt_uri_object("Work#{w_count}PrimaryContribution#{count}", bf_agent_predicate, artist["name"])
          stmts << contruct_stmt_uri_object(artist["name"], rdf_type_predicate, bf_agent_type_object)
          count += 1
        end
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end

      # @param [Array] discogs extraartists associated with a track
      # @param [Integer] used to give unique URIS for works, contributions and roles
      # @return [Array] rdf statements
      def build_track_extraartists(extraartists, w_count)
        stmts = []
        # to distinguish among contributors to a track/work and their roles
        count = 1
        extraartists.each do |artist|
          stmts << contruct_stmt_uri_object("Work#{w_count}", "http://id.loc.gov/ontologies/bibframe/contribution", "Work#{w_count}Contribution#{count}")
          stmts << contruct_stmt_uri_object("Work#{w_count}Contribution#{count}", rdf_type_predicate, "http://id.loc.gov/ontologies/bibframe/Contribution")
          stmts << contruct_stmt_uri_object("Work#{w_count}Contribution#{count}", bf_agent_predicate, artist["name"])
          stmts << contruct_stmt_uri_object(artist["name"], rdf_type_predicate, bf_agent_type_object)
          stmts << contruct_stmt_uri_object(artist["name"], bf_role_predicate, "Work#{w_count}ContributorRole#{count}")
          stmts << contruct_stmt_uri_object("Work#{w_count}ContributorRole#{count}", rdf_type_predicate, bf_role_type_object)
          stmts << contruct_stmt_literal_object("Work#{w_count}ContributorRole#{count}", rdfs_label_predicate, artist["role"])
          count += 1
        end
        stmts # w/out this line, building the graph throws an undefined method `graph_name=' error
      end
    end
  end
end
