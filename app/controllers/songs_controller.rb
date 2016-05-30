class SongsController < InheritedResources::Base
  layout Proc.new { |controller| controller.request.xhr? ? false : 'appfixed' }

  def index
    @q = params[:q]
    per_page = 15
    if @q
      @search = Sunspot.search(Song) do |s|
        s.keywords @q
        
        s.paginate :page => params[:page], :per_page => per_page
      end
      @songs = @search.results
    else
      @songs = Song.page(params[:page]).per(per_page)
    end
  end
end
