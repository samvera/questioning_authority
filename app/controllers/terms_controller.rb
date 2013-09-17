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
    
    #use the appropriate class (get the name from the hash map) and retrieve the vocabulary
    @results = vocabularies[params[:vocab]].constantize.new(params[:q])

    respond_to do |format|
      format.html { render :layout => false, :text => @results.to_json }
      format.json { render :layout => false, :text => @results.to_json }
      format.js   { render :layout => false, :text => @results.to_json }
    end
  end


end
