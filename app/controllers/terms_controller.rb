# This controller is used for all requests to all authorities. It will verify params and figure out
# which class to instantiate based on the "vocab" param. All the authotirty classes inherit from a
# super class so they implement the same methods.

class TermsController < ApplicationController

  before_action :check_params, :check_authority
  
  def index
    
    
    #get the authority class
    authority_class = authorities_classes[params[:vocab]]
    
    #convert wildcard to be URI encoded
    params[:q].gsub!("*", "%2A")
   
    #initialize the authority and run the search. if there's a sub-authority and it's valid, include that param
    if params[:sub_authority].present?
      if authority_class.constantize.authority_valid?(params[:sub_authority])
        @authority = authority_class.constantize.new(params[:q], params[:sub_authority])
      else
        raise Exception, 'Sub-authority not valid'
      end
    else
      @authority = authority_class.constantize.new(params[:q])
    end
    
    #parse the results
    @authority.parse_authority_response
    
    respond_to do |format|
      format.html { render :layout => false, :text => @authority.results }
      format.json { render :layout => false, :text => @authority.results }
      format.js   { render :layout => false, :text => @authority.results }
    end



  end


  def check_params
    unless params[:q].present? && params[:vocab].present?
      redirect_to :status => 400
    end
  end

  def check_authority
    begin
      ("Authorities::"+params[:vocab]).constantize
    rescue
      redirect_to :status => 400
    end 
  end

end
