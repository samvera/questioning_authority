# This controller is used for all requests to linked data authorities. It will verify params and figure
# out which linked data authority to query based on the 'vocab' param.

class Qa::LinkedDataTermsController < ApplicationController
  before_action :check_authority, :init_authority
  before_action :check_search_subauthority, :check_query_param, only: :search
  before_action :check_show_subauthority, :check_id_param, only: :show

  # Provide a warning if there is a request for all terms.
  def index
    logger.warn 'Linked data authorities do not support retrieving all terms.'
    head :not_found
  end

  # Return a list of terms based on a query
  # @see Qa::Authorities::LinkedData::SearchQuery#search
  def search
    begin
      terms = @authority.search(query, subauth: subauthority, language: language, replacements: replacement_params)
    rescue Qa::ServiceUnavailable
      logger.warn "Service Unavailable - Search query #{query} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
      head :service_unavailable
      return
    rescue Qa::ServiceError
      logger.warn "Internal Server Error - Search query #{query} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
      head :internal_server_error
      return
    rescue RDF::FormatError
      logger.warn "RDF Format Error - Results from search query #{query} for#{subauth_warn_msg} authority #{vocab_param} was not identified as a valid RDF format.  You may need to include the linkeddata gem."
      head :internal_server_error
      return
    end
    render json: terms
  end

  # Return all the information for a given term
  # @see Qa::Authorities::LinkedData::FindTerm#find
  def show
    begin
      term = @authority.find(id, subauth: subauthority, language: language, replacements: replacement_params)
    rescue Qa::TermNotFound
      logger.warn "Term Not Found - Fetch term #{id} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
      head :not_found
      return
    rescue Qa::ServiceUnavailable
      logger.warn "Service Unavailable - Fetch term #{id} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
      head :service_unavailable
      return
    rescue Qa::ServiceError
      logger.warn "Internal Server Error - Fetch term #{id} unsuccessful for#{subauth_warn_msg} authority #{vocab_param}"
      head :internal_server_error
      return
    rescue RDF::FormatError
      logger.warn "RDF Format Error - Results from fetch term #{id} for#{subauth_warn_msg} authority #{vocab_param} was not identified as a valid RDF format.  You may need to include the linkeddata gem."
      head :internal_server_error
      return
    end
    render json: term
  end

  private

    def check_authority
      if params[:vocab].nil? || !params[:vocab].size.positive?
        logger.warn "Required param 'vocab' is missing or empty"
        head :bad_request
      end
    end

    def check_search_subauthority
      return if subauthority.nil?
      unless @authority.search_subauthority?(subauthority)
        logger.warn "Unable to initialize linked data search sub-authority '#{subauthority}' for authority '#{vocab_param}'"
        head :bad_request
      end
    end

    def check_show_subauthority
      return if subauthority.nil?
      unless @authority.term_subauthority?(subauthority)
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
      if params[:q].nil? || !params[:q].size.positive?
        logger.warn "Required search param 'q' is missing or empty"
        head :bad_request
      end
    end

    # converts wildcards into URL-encoded characters
    def query
      params[:q].gsub("*", "%2A")
    end

    def check_id_param
      if params[:id].nil? || !params[:id].size.positive?
        logger.warn "Required show param 'id' is missing or empty"
        head :bad_request
      end
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
end
