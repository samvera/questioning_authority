# This controller is used for all requests to linked data authorities. It will verify params and figure
# out which linked data authority to query based on the 'vocab' param.

class Qa::LinkedDataTermsController < ApplicationController
  before_action :check_vocab_param, :init_authority
  before_action :check_query_param, only: :search
  before_action :check_id_param, only: :show

  # Provide a warning if there is a request for all terms.
  def index
    logger.warn 'Linked data authorities do not support retrieving all terms.'
    head :not_found
  end

  # Return a list of terms based on a query
  def search
    subauth = subauthority
    unless subauth.nil? || @authority.search_subauthority?(subauth)
      logger.warn "Unable to initialize linked data search sub-authority #{subauth} for authority #{vocab_param}"
      head :not_found
      return
    end
    terms = @authority.search(query, subauth: subauthority, language: language, replacements: replacement_params)
    render json: terms
  end

  # Return all the information for a given term
  def show
    subauth = subauthority
    unless subauth.nil? || @authority.term_subauthority?(subauth)
      logger.warn "Unable to initialize linked data term sub-authority #{subauth} for authority #{vocab_param}"
      head :not_found
      return
    end
    begin
      term = @authority.find(id, subauth: subauthority, language: language, replacements: replacement_params)
    rescue Qa::ServiceUnavailable, Qa::TermNotFound => e
      err_cause = 'Term Not Found'
      err_cause = 'Service Unavailable' if e.is_a? Qa::ServiceUnavailable
      subauth_msg = subauth.nil? ? "" : " sub-authority #{subauth} in"
      logger.warn "#{err_cause} - Fetch term #{id} unsuccessful for#{subauth_msg} authority #{vocab_param}"
      head :not_found
      return
      # render text: "<h3>#{err_cause} - Fetch term #{id} unsuccessful for#{subauth_msg} authority #{vocab_param}</h3><p>Exception message: #{e.message}</p>" && return
    end
    render json: term
  end

  private

    def check_vocab_param
      head :not_found unless params[:vocab].present?
    end

    def init_authority
      begin
        authority = vocab_param
      rescue NameError
        logger.warn "Unable to initialize authority #{vocab_param}"
        head :not_found
        return
      end
      if authority.nil?
        logger.warn "Unable to initialize authority #{params[:q]}"
        head :not_found
        return
      end
      begin
        @authority = Qa::Authorities::LinkedData::GenericAuthority.new(authority)
      rescue Qa::InvalidLinkedDataAuthority => e
        logger.warn e.message
        head :not_found
      end
    end

    def vocab_param
      params[:vocab].upcase.to_sym
    end

    def check_query_param
      head :not_found unless params[:q].present?
    end

    # converts wildcards into URL-encoded characters
    def query
      params[:q].gsub("*", "%2A")
    end

    def check_id_param
      head :not_found unless params[:id].present?
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
      params.reject { |k, _v| ['q', 'vocab', 'controller', 'action', 'subauthority', 'language'].include?(k) }
    end
end
