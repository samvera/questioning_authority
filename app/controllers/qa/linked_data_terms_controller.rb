# This controller is used for all requests to linked data authorities. It will verify params and figure
# out which linked data authority to query based on the 'vocab' param.

class Qa::LinkedDataTermsController < ::ApplicationController
  before_action :check_authority, :init_authority, except: [:list, :reload]
  before_action :check_search_subauthority, :check_query_param, only: :search
  before_action :check_show_subauthority, :check_id_param, only: :show
  before_action :check_uri_param, only: :fetch
  before_action :validate_auth_reload_token, only: :reload

  delegate :cors_allow_origin_header, to: Qa::ApplicationController

  # Provide a warning if there is a request for all terms.
  def index
    logger.warn 'Linked data authorities do not support retrieving all terms.'
    head :not_found
  end

  # Return a list of supported authority names
  # get "/list/linked_data/authorities"
  # @see Qa::LinkedData::AuthorityService#authority_names
  def list
    render json: Qa::LinkedData::AuthorityService.authority_names.to_json
  end

  # Reload authority configurations
  # get "/reload/linked_data/authorities?auth_token=YOUR_AUTH_TOKEN_DEFINED_HERE"
  # @see Qa::LinkedData::AuthorityService#load_authorities
  def reload
    Qa::LinkedData::AuthorityService.load_authorities
    list
  end

  # Return a list of terms based on a query
  # get "/search/linked_data/:vocab(/:subauthority)"
  # @see Qa::Authorities::LinkedData::SearchQuery#search
  def search
    terms = @authority.search(query, subauth: subauthority, language: language, replacements: replacement_params)
    cors_allow_origin_header(response)
    render json: terms
  rescue Qa::ServiceUnavailable
    logger.warn "Service Unavailable - Search query #{query} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    head :service_unavailable
  rescue Qa::ServiceError
    logger.warn "Internal Server Error - Search query #{query} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    head :internal_server_error
  rescue RDF::FormatError
    logger.warn "RDF Format Error - Results from search query #{query} for#{subauth_warn_msg} authority #{vocab_param} " \
                "was not identified as a valid RDF format.  You may need to include the linkeddata gem."
    head :internal_server_error
  end

  # Return all the information for a given term given an id or URI
  # get "/show/linked_data/:vocab/:id"
  # get "/show/linked_data/:vocab/:subauthority/:id
  # @see Qa::Authorities::LinkedData::FindTerm#find
  def show # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    term = @authority.find(id, subauth: subauthority, language: language, replacements: replacement_params, jsonld: jsonld?)
    cors_allow_origin_header(response)
    content_type = jsonld? ? 'application/ld+json' : 'application/json'
    render json: term, content_type: content_type
  rescue Qa::TermNotFound
    logger.warn "Term Not Found - Fetch term #{id} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    head :not_found
  rescue Qa::ServiceUnavailable
    logger.warn "Service Unavailable - Fetch term #{id} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    head :service_unavailable
  rescue Qa::ServiceError
    logger.warn "Internal Server Error - Fetch term #{id} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    head :internal_server_error
  rescue RDF::FormatError
    logger.warn "RDF Format Error - Results from fetch term #{id} for#{subauth_warn_msg} authority #{vocab_param} " \
                "was not identified as a valid RDF format.  You may need to include the linkeddata gem."
    head :internal_server_error
  end

  # Return all the information for a given term given a URI
  # get "/fetch/linked_data/:vocab"
  # @see Qa::Authorities::LinkedData::FindTerm#find
  def fetch # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    term = @authority.find(uri, subauth: subauthority, language: language, replacements: replacement_params, jsonld: jsonld?)
    cors_allow_origin_header(response)
    content_type = jsonld? ? 'application/ld+json' : 'application/json'
    render json: term, content_type: content_type
  rescue Qa::TermNotFound
    logger.warn "Term Not Found - Fetch term #{uri} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    head :not_found
  rescue Qa::ServiceUnavailable
    logger.warn "Service Unavailable - Fetch term #{uri} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    head :service_unavailable
  rescue Qa::ServiceError
    logger.warn "Internal Server Error - Fetch term #{uri} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    head :internal_server_error
  rescue RDF::FormatError
    logger.warn "RDF Format Error - Results from fetch term #{uri} for#{subauth_warn_msg} authority #{vocab_param} " \
                "was not identified as a valid RDF format.  You may need to include the linkeddata gem."
    head :internal_server_error
  end

  private

    def check_authority
      if params[:vocab].nil? || !params[:vocab].size.positive? # rubocop:disable Style/GuardClause
        logger.warn "Required param 'vocab' is missing or empty"
        head :bad_request
      end
    end

    def check_search_subauthority
      return if subauthority.nil?
      unless @authority.search_subauthority?(subauthority) # rubocop:disable Style/GuardClause
        logger.warn "Unable to initialize linked data search sub-authority '#{subauthority}' for authority '#{vocab_param}'"
        head :bad_request
      end
    end

    def check_show_subauthority
      return if subauthority.nil?
      unless @authority.term_subauthority?(subauthority) # rubocop:disable Style/GuardClause
        logger.warn "Unable to initialize linked data term sub-authority '#{subauthority}' for authority '#{vocab_param}'"
        head :bad_request
      end
    end

    def init_authority
      @authority = Qa::Authorities::LinkedData::GenericAuthority.new(vocab_param)
    rescue Qa::InvalidLinkedDataAuthority => e
      logger.warn e.message
      head :bad_request
    end

    def vocab_param
      params[:vocab].upcase.to_sym
    end

    def check_query_param
      missing_required_param('search', 'q') if params[:q].blank?
    end

    def check_id_param
      missing_required_param('show', 'id') if id.blank?
    end

    def check_uri_param
      missing_required_param('fetch', 'uri') if uri.blank?
    end

    def missing_required_param(action_name, param_name)
      logger.warn "Required #{action_name} param '#{param_name}' is missing or empty"
      head :bad_request
    end

    # converts wildcards into URL-encoded characters
    def query
      params[:q].gsub("*", "%2A")
    end

    def uri
      params[:uri]
    end

    def id
      params[:id]
    end

    def language
      params[:lang]
    end

    def subauthority
      params[:subauthority]
    end

    def replacement_params
      params.reject { |k, _v| ['q', 'vocab', 'controller', 'action', 'subauthority', 'language', 'id'].include?(k) }
    end

    def subauth_warn_msg
      subauthority.nil? ? "" : " sub-authority #{subauthority} in"
    end

    def format
      return 'json' unless params.key?(:format)
      return 'json' if params[:format].blank?
      params[:format]
    end

    def jsonld?
      format == 'jsonld'
    end

    def validate_auth_reload_token
      token = params.key?(:auth_token) ? params[:auth_token] : nil
      valid = Qa.config.valid_authority_reload_token?(token)
      return true if valid
      logger.warn "FAIL: unable to reload authorities; error_msg: Invalid token (#{token}) does not match expected token."
      head :unauthorized
      false
    end
end
