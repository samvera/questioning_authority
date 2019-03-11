# This controller is used for all requests to all authorities. It will verify
# params and figure out which class to instantiate based on the "vocab" param.
# All the authority classes inherit from a super class so they implement the
# same methods.

class Qa::TermsController < ::ApplicationController
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
    render json: terms
  end

  # If the subauthority supports it, return all the information for a given term
  def show
    term = @authority.method(:find).arity == 2 ? @authority.find(params[:id], self) : @authority.find(params[:id])
    cors_allow_origin_header(response)
    content_type = params["format"] == "jsonld" ? 'application/ld+json' : 'application/json'
    render json: term, content_type: content_type
  end

  def check_vocab_param
    return if params[:vocab].present?
    msg = "Required param 'vocab' is missing or empty"
    logger.warn msg
    render json: { errors: msg }, status: :bad_request
  end

  def init_authority # rubocop:disable Metrics/MethodLength
    begin
      mod = authority_class.camelize.constantize
    rescue NameError
      msg = "Unable to initialize authority #{authority_class}"
      logger.warn msg
      render json: { errors: msg }, status: :bad_request
      return
    end
    begin
      @authority = if mod.is_a? Class
                     mod.new
                   else
                     raise Qa::MissingSubAuthority, "No sub-authority provided" if params[:subauthority].blank?
                     mod.subauthority_for(params[:subauthority])
                   end
    rescue Qa::InvalidSubAuthority, Qa::MissingSubAuthority => e
      msg = e.message
      logger.warn msg
      render json: { errors: msg }, status: :bad_request
    end
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
end
