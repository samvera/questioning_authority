# This controller is used for all requests to linked data authorities. It will verify params and figure
# out which linked data authority to query based on the 'vocab' param.

class Qa::LinkedDataTermsController < ::ApplicationController
  before_action :check_authority, :init_authority, except: [:list, :reload]
  before_action :check_search_subauthority, :check_query_param, only: :search
  before_action :check_show_subauthority, :check_id_param, only: :show
  before_action :check_uri_param, only: :fetch
  before_action :validate_auth_reload_token, only: :reload
  before_action :create_request_header_service, only: [:search, :show, :fetch]

  delegate :cors_allow_origin_header, to: Qa::ApplicationController

  class_attribute :request_header_service_class
  self.request_header_service_class = Qa::LinkedData::RequestHeaderService

  attr_reader :request_header_service

  # Provide a warning if there is a request for all terms.
  def index
    logger.warn 'Linked data authorities do not support retrieving all terms.'
    head :not_found
  end

  # Return a list of supported authority names optionally with details about the authority
  # get "/list/linked_data/authorities?details=true|false" (default details=false)
  # @see Qa::LinkedData::AuthorityService#authority_names
  # @see Qa::LinkedData::AuthorityService#authority_details
  def list
    details? ? render_detail_list : render_simple_list
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
  def search # rubocop:disable Metrics/MethodLength
    terms = @authority.search(query, request_header: request_header_service.search_header)
    cors_allow_origin_header(response)
    render json: terms
  rescue Qa::ServiceUnavailable
    msg = "Service Unavailable - Search query #{query} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    logger.warn msg
    render json: { errors: msg }, status: :service_unavailable
  rescue Qa::ServiceError
    msg = "Internal Server Error - Search query #{query} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    logger.warn msg
    render json: { errors: msg }, status: :internal_server_error
  rescue RDF::FormatError
    msg = "RDF Format Error - Results from search query #{query} for#{subauth_warn_msg} authority #{vocab_param} " \
                "was not identified as a valid RDF format.  You may need to include the linkeddata gem."
    logger.warn msg
    render json: { errors: msg }, status: :internal_server_error
  end

  # Return all the information for a given term given an id or URI
  # get "/show/linked_data/:vocab/:id"
  # get "/show/linked_data/:vocab/:subauthority/:id
  # @see Qa::Authorities::LinkedData::FindTerm#find
  def show # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    term = @authority.find(id, request_header: request_header_service.fetch_header)
    cors_allow_origin_header(response)
    render json: term, content_type: request_header_service.content_type_for_format
  rescue Qa::TermNotFound
    msg = "Term Not Found - Fetch term #{id} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    logger.warn msg
    render json: { errors: msg }, status: :not_found
  rescue Qa::ServiceUnavailable
    msg = "Service Unavailable - Fetch term #{id} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    logger.warn msg
    render json: { errors: msg }, status: :service_unavailable
  rescue Qa::ServiceError
    msg = "Internal Server Error - Fetch term #{id} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    logger.warn msg
    render json: { errors: msg }, status: :internal_server_error
  rescue RDF::FormatError
    msg = "RDF Format Error - Results from fetch term #{id} for#{subauth_warn_msg} authority #{vocab_param} " \
                "was not identified as a valid RDF format.  You may need to include the linkeddata gem."
    logger.warn msg
    render json: { errors: msg }, status: :internal_server_error
  rescue Qa::DataNormalizationError => e
    msg = "Data Normalization Error - #{e.message}"
    logger.warn msg
    render json: { errors: msg }, status: :internal_server_error
  end

  # Return all the information for a given term given a URI
  # get "/fetch/linked_data/:vocab"
  # @see Qa::Authorities::LinkedData::FindTerm#find
  def fetch # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    term = @authority.find(uri, request_header: request_header_service.fetch_header)
    cors_allow_origin_header(response)
    render json: term, content_type: request_header_service.content_type_for_format
  rescue Qa::TermNotFound
    msg = "Term Not Found - Fetch term #{uri} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    logger.warn msg
    render json: { errors: msg }, status: :not_found
  rescue Qa::ServiceUnavailable
    msg = "Service Unavailable - Fetch term #{uri} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    logger.warn msg
    render json: { errors: msg }, status: :service_unavailable
  rescue Qa::ServiceError
    msg = "Internal Server Error - Fetch term #{uri} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
    logger.warn msg
    render json: { errors: msg }, status: :internal_server_error
  rescue RDF::FormatError
    msg = "RDF Format Error - Results from fetch term #{uri} for#{subauth_warn_msg} authority #{vocab_param} " \
                "was not identified as a valid RDF format.  You may need to include the linkeddata gem."
    logger.warn msg
    render json: { errors: msg }, status: :internal_server_error
  end

  private

    def render_simple_list
      render json: Qa::LinkedData::AuthorityService.authority_names.to_json
    end

    def render_detail_list
      render json: Qa::LinkedData::AuthorityService.authority_details.to_json
    end

    def check_authority
      if params[:vocab].nil? || !params[:vocab].size.positive? # rubocop:disable Style/GuardClause
        msg = "Required param 'vocab' is missing or empty"
        logger.warn msg
        render json: { errors: msg }, status: :bad_request
      end
    end

    def check_search_subauthority
      return if subauthority.nil?
      unless @authority.search_subauthority?(subauthority) # rubocop:disable Style/GuardClause
        msg = "Unable to initialize linked data search sub-authority '#{subauthority}' for authority '#{vocab_param}'"
        logger.warn msg
        render json: { errors: msg }, status: :bad_request
      end
    end

    def check_show_subauthority
      return if subauthority.nil?
      unless @authority.term_subauthority?(subauthority) # rubocop:disable Style/GuardClause
        msg = "Unable to initialize linked data term sub-authority '#{subauthority}' for authority '#{vocab_param}'"
        logger.warn msg
        render json: { errors: msg }, status: :bad_request
      end
    end

    def create_request_header_service
      @request_header_service = request_header_service_class.new(request: request, params: params)
    end

    def init_authority
      @authority = Qa.authority_for(vocab: params[:vocab], subauthority: params[:subauthority])
    rescue Qa::InvalidAuthorityError, Qa::InvalidLinkedDataAuthority => e
      msg = e.message
      logger.warn msg
      render json: { errors: msg }, status: :bad_request
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
      msg = "Required #{action_name} param '#{param_name}' is missing or empty"
      logger.warn msg
      render json: { errors: msg }, status: :bad_request
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

    def subauthority
      params[:subauthority]
    end

    def subauth_warn_msg
      subauthority.blank? ? "" : " sub-authority #{subauthority} in"
    end

    def details?
      details = params.fetch(:details, 'false')
      details.casecmp?('true')
    end

    def validate_auth_reload_token
      token = params.key?(:auth_token) ? params[:auth_token] : nil
      valid = Qa.config.valid_authority_reload_token?(token)
      return true if valid
      msg = "FAIL: unable to reload authorities; error_msg: Invalid token (#{token}) does not match expected token."
      logger.warn msg
      render json: { errors: msg }, status: :unauthorized
      false
    end
end
