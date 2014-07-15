# This controller is used for all requests to all authorities. It will verify params and figure out
# which class to instantiate based on the "vocab" param. All the authotirty classes inherit from a
# super class so they implement the same methods.

class Qa::TermsController < ApplicationController

  before_action :check_vocab_param, :init_authority

  # If the subauthority supports it, return a list of all terms in the authority
  def index
    render json: @authority.all
  end

  # Return a list of terms based on a query
  # - converts query wildcards appropriately  
  def search
    params[:q].gsub!("*", "%2A") if params[:q]
    terms = @authority.search(params[:q])
    render json: terms
  end

  # If the subauthority supports it, return all the information for a given term
  def show
    term = @authority.find(params[:id])
    render json: term
  end

  def check_vocab_param
    unless params[:vocab].present?
      head :not_found
    end
  end

  def init_authority
    @authority = authority_class.constantize.new(params[:sub_authority])
  rescue
    head :not_found
  end

  private

  def authority_class
    "Qa::Authorities::"+params[:vocab].capitalize
  end

end
