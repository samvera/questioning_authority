# This controller is used for all requests to all authorities. It will verify params and figure out
# which class to instantiate based on the "vocab" param. All the authotirty classes inherit from a
# super class so they implement the same methods.

class TermsController < ApplicationController

  before_action :check_search_params, only:[:search]
  before_action :check_vocab_param, :check_authority, :check_sub_authority
  
  #search that returns all results
  def index
    #initialize the authority and run the search. if there's a sub-authority and it's valid, include that param
    @authority = authority_class.constantize.new(params[:q], params[:sub_authority])
    
    #parse the results
    @authority.parse_authority_response
    
    respond_to do |format|
      format.html { render :layout => false, :text => @authority.results }
      format.json { render :layout => false, :text => @authority.results }
      format.js   { render :layout => false, :text => @authority.results }
    end
  end
  
  def search
    
    #convert wildcard to be URI encoded
    params[:q].gsub!("*", "%2A")
   
    #initialize the authority and run the search. if there's a sub-authority and it's valid, include that param
    @authority = authority_class.constantize.new(params[:q], params[:sub_authority])
    
    #parse the results
    @authority.parse_authority_response
    
    respond_to do |format|
      format.html { render :layout => false, :text => @authority.results }
      format.json { render :layout => false, :text => @authority.results }
      format.js   { render :layout => false, :text => @authority.results }
    end

  end

  def check_vocab_param
    unless params[:vocab].present?
      redirect_to :status => 400
    end
  end
  
  def check_search_params
    unless params[:q].present? && params[:vocab].present?
      redirect_to :status => 400
    end
  end

  def check_authority
    begin
      authority_class.constantize
    rescue
      redirect_to :status => 400
    end 
  end

  def check_sub_authority
    unless params[:sub_authority].nil?
      redirect_to :status => 400 unless authority_class.constantize.authority_valid?(params[:sub_authority])
    end
  end

  private

  def authority_class
    "Authorities::"+params[:vocab].capitalize
  end

end
