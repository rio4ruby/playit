class ArtistsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? false : 'appfixed' }

  def index
    @q = params[:q]
    per_page = 15
    @q ||= ""
    @search = Sunspot.search(Artist) do |s|
      s.keywords @q
      s.paginate :page => params[:page], :per_page => per_page
    end
    @artists = @search.results
  end


  def search
    @q = params[:q]
    per_page = 15
    if @q
      @search = Sunspot.search(Artist) do |s|
        s.keywords @q
        
        s.paginate :page => params[:page], :per_page => per_page
      end
      @artists = @search.results
    else
      @artists = Artist.page(params[:page]).per(per_page)
    end

    respond_to do |format|
      format.html { render 'index' }
    end



  end


end
