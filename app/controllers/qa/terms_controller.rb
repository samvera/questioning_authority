# This controller is used for all requests to all authorities. It will verify
# params and figure out which class to instantiate based on the "vocab" param.
# All the authority classes inherit from a super class so they implement the
# same methods.

class Qa::TermsController < ::ApplicationController
  class_attribute :pagination_service_class
  self.pagination_service_class = Qa::PaginationService

  before_action :check_vocab_param, :init_authority
  before_action :check_query_param, only: :search

  delegate :cors_allow_origin_header, to: Qa::ApplicationController

  # If the subauthority supports it, return a list of all terms in the authority
  def index
    cors_allow_origin_header(response)
    render json: begin
      @authority.all
    rescue NotImplementedError
      nil
    end
  end

  # Return a list of terms based on a query
  def search
    terms = @authority.method(:search).arity == 2 ? @authority.search(url_search, self) : @authority.search(url_search)
    cors_allow_origin_header(response)
    respond_to do |wants|
      wants.json { render json: pagination_service(format: :json, results: terms).build_response }
      wants.jsonapi { render json: pagination_service(format: :jsonapi, results: terms).build_response }
      wants.any { render json: pagination_service(format: :json, results: terms).build_response, content_type: json_content_type }
    end
  end

  # If the subauthority supports it, return all the information for a given term
  # Expects id to be part of the request path (e.g. http://my.app/qa/show/auth/subauth/{:id})
  def show
    term = @authority.method(:find).arity == 2 ? @authority.find(params[:id], self) : @authority.find(params[:id])
    cors_allow_origin_header(response)
    respond_to do |wants|
      wants.json { render json: term }
      wants.n3 { render json: term }
      wants.jsonld { render json: term }
      wants.ntriples { render json: term }
      wants.any { render json: term, content_type: json_content_type }
    end
  end

  # If the subauthority supports it, return all the information for a given term
  # Expects uri to be a request parameter (e.g. http://my.app/qa/show/auth/subauth?uri={:uri})
  def fetch
    term = @authority.method(:find).arity == 2 ? @authority.find(params[:uri], self) : @authority.find(params[:uri])
    cors_allow_origin_header(response)
    respond_to do |wants|
      wants.json { render json: term }
      wants.n3 { render json: term }
      wants.jsonld { render json: term }
      wants.ntriples { render json: term }
      wants.any { render json: term, content_type: json_content_type }
    end
  end

  def check_vocab_param
    return if params[:vocab].present?
    msg = "Required param 'vocab' is missing or empty"
    logger.warn msg
    render json: { errors: msg }, status: :bad_request
  end

  def init_authority # rubocop:disable Metrics/MethodLength
    @authority = Qa.authority_for(vocab: params[:vocab],
                                  subauthority: params[:subauthority],
                                  # Included to preserve error message text
                                  try_linked_data_config: false,
                                  context: self)
  rescue Qa::InvalidAuthorityError, Qa::InvalidSubAuthority, Qa::MissingSubAuthority => e
    msg = e.message
    logger.warn msg
    render json: { errors: msg }, status: :bad_request
  end

  def check_query_param
    return if params[:q].present?
    msg = "Required param 'q' is missing or empty"
    logger.warn msg
    render json: { errors: msg }, status: :bad_request
  end

  private

    def authority_class
      "Qa::Authorities::" + params[:vocab].capitalize
    end

    # converts wildcards into URL-encoded characters
    def url_search
      params[:q].gsub("*", "%2A")
    end

    def json_content_type
      Mime::Type.lookup_by_extension(:json).to_str
    end

    def pagination_service(results:, format:)
      pagination_service_class.new(request: request, results: results, format: format)
    end
end
