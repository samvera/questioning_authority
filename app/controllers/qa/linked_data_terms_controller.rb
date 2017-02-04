# This controller is used for all requests to linked data authorities. It will verify params and figure
# out which linked data authority to query based on the "vocab" param.

class Qa::LinkedDataTermsController < ApplicationController
  before_action :check_vocab_param, :init_authority
  before_action :check_query_param, only: :search

  # If the subauthority supports it, return a list of all terms in the authority
  def index
    render json: @authority.all
  end

  # Return a list of terms based on a query
  def search
    terms = @authority.search(query, language, replacement_params)
    render json: terms
  end

  # If the subauthority supports it, return all the information for a given term
  def show
    begin
      term = @authority.find(params[:id], language, replacement_params)
    rescue Qa::ServiceUnavailable, Qa::TermNotFound => e
      title = "Term Not Found"
      title = "Service Unavailable" if e.is_a? Qa::ServiceUnavailable
      render text: "<h1>#{title}</h1><p>#{e.message}</p>" && return
    end
    render json: term
  end

  def check_vocab_param
    head :not_found unless params[:vocab].present?
  end

  def init_authority
    begin
      vocab = authority_symbol
    rescue NameError
      logger.warn "Unable to initialize authority #{authority_symbol}"
      head :not_found
      return
    end
    if vocab.nil?
      logger.warn "Unable to initialize authority #{params[:q]}"
      head :not_found
      return
    end
    begin
      @authority = Qa::Authorities::LinkedData::GenericAuthority.new(vocab, search_subauthority, term_subauthority)
    rescue Qa::InvalidLinkedDataAuthority => e
      logger.warn e.message
      head :not_found
    end
  end

  def check_query_param
    head :not_found unless params[:q].present?
  end

  private

    def authority_symbol
      params[:vocab].upcase.to_sym
    end

    def language
      params[:lang]
    end

    def search_subauthority
      return nil unless params[:action] == "search"
      subauthority
    end

    def term_subauthority
      return nil unless params[:action] == "show"
      subauthority
    end

    def subauthority
      params[:subauthority]
    end

    # converts wildcards into URL-encoded characters
    def query
      params[:q].gsub("*", "%2A")
    end

    def replacement_params
      params.reject { |k, _v| ["q", "vocab", "controller", "action"].include?(k) }
    end
end
