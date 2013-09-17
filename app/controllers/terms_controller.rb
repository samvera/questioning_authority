class TermsController < ApplicationController
  
  def index
    
    #these are the supported vocabularies and the associated class names
    vocabularies = {"lcsh"=>"Authorities::Lcsh", "loc"=>"Authorities::Loc"}
    
    #make sure vocab param is present
    if !params[:vocab].present?
      raise Exception, 'The vocabulary was not specified'
    end
    
    #make sure q param is present
    if !params[:q].present?
      raise Exception, 'The query was not specified'
    end
    
    #make sure vocab param is valid
    if !vocabularies.has_key? params[:vocab]
      raise Exception, 'Vocabulary not supported'
    end
    
    #convert wildcard to be URI encoded
    params[:q].gsub!("*", "%2A")

    #use the appropriate class (get the name from the hash map) and retrieve the vocabulary
    if params[:sub_authority].present?
      @results = vocabularies[params[:vocab]].constantize.new(params[:q], params[:sub_authority])
    else
      @results = vocabularies[params[:vocab]].constantize.new(params[:q])
    end
    
    respond_to do |format|
      format.html { render :layout => false, :text => @results.to_json }
      format.json { render :layout => false, :text => @results.to_json }
      format.js   { render :layout => false, :text => @results.to_json }
    end
  end


end
