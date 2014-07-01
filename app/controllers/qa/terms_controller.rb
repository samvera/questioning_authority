# This controller is used for all requests to all authorities. It will verify params and figure out
# which class to instantiate based on the "vocab" param. All the authotirty classes inherit from a
# super class so they implement the same methods.

class Qa::TermsController < ApplicationController

  before_action :check_vocab_param, :init_authority, :check_sub_authority

  # If the subauthority supports it, return a list of all terms in the authority
  def index
    @authority.all(params[:sub_authority])
    render json: @authority.response
  end

  # Return a list of terms based on a query
  # - converts query wildcards appropriately  
  def search
    params[:q].gsub!("*", "%2A") if params[:q]
    @authority.search(params[:q], params[:sub_authority])
    render json: @authority.response
  end

  # If the subauthority supports it, return all the information for a given term
  def show
    result = @authority.full_record(params[:id], params[:sub_authority])
    render json: result
  end

  def check_vocab_param
    unless params[:vocab].present?
      head :not_found
    end
  end

  def init_authority
    @authority = authority_class.constantize.new
  rescue
    head :not_found
  end

  def check_sub_authority
    unless params[:sub_authority].nil?
      head :not_found unless authority_class.constantize.authority_valid?(params[:sub_authority])
    end
  end

  private

  def authority_class
    "Qa::Authorities::"+params[:vocab].capitalize
  end

end
