class TermsController < ApplicationController

  def index
    @results = Authorities::Lcsh.new(params[:q]) if params[:q]

    respond_to do |format|
      format.html { render :layout => false, :text => @results.to_json }
      format.json { render :layout => false, :text => @results.to_json }
      format.js   { render :layout => false, :text => @results.to_json }
    end
  end

end
