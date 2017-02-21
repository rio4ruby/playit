class HomeController < ApplicationController
  before_filter :authenticate_user!

  layout Proc.new { |controller| controller.request.xhr? ? 'search_result' : 'appfixed' }

  def index
    Rails.logger.info("Index Search: #{params}")
    @q = params[:q]
    @q ||= ""

    if @q
      srch = [Artist,Album,AudioFile].select{|c| params[c.to_s.to_sym]}
      srch = [Artist,Album,AudioFile] if srch.empty?
      per_page = 10
      @search = Sunspot.search(*srch) do |s|
        s.data_accessor_for(Lyric).include = [:artist, :song]
        s.data_accessor_for(Album).include = [:album_artist, { audio_files: [:song, :artist, { file_dir: :image_files}] }]
        s.data_accessor_for(AudioFile).include = [:album, :artist, :song, :file_dir]
        s.data_accessor_for(Artist).include = [:albums, { audio_files: [:album, :song, :file_dir] } ]
        s.order_by(:random) if @q == ""
        s.keywords @q
        
        s.paginate :page => params[:page], :per_page => per_page
      end
    end

    respond_to do |format|
      format.html
    end

  end

  def main
    Rails.logger.info("Main Search: #{params}")
    @q = params[:q]
    @q ||= ""

    if @q
      srch = [Artist,Album,AudioFile].select{|c| params[c.to_s.to_sym]}
      srch = [Artist,Album,AudioFile] if srch.empty?
      per_page = 10
      @search = Sunspot.search(*srch) do |s|
        s.order_by(:random) if @q == ""
        s.keywords @q
        
        s.paginate :page => params[:page], :per_page => per_page
      end
    end

    respond_to do |format|
      format.html
    end

  end



# match artist because name matches
# match album because name matches
# match track because song.name matches

# match album because artist.name matches
# match album because song.name matches

# match artist because album.name matches
# match artist because song.name matches

# match track because album.name matches
# match track because artist.name matches


  def playing_lyrics
    Rails.logger.info("Playing lyrics: #{params}")
    @playing_id = params.inspect
    Rails.logger.info("Playing ID: #{@playing_id}")
    cky = cookies[:playing]
    ln_el,af_el,alb_el = cky.split('--')
    @audio_file = elem_id_to_record(af_el);
    
    Rails.logger.info("Cookie: #{cky}")
    respond_to do |format|
      format.html
    end
  end

  def playing_wiki
    Rails.logger.info("Playing wiki: #{params}")
    @playing_id = params.inspect
    Rails.logger.info("Playing ID: #{@playing_id}")
    cky = cookies[:playing]
    ln_el,af_el,alb_el = cky.split('--')
    @audio_file = elem_id_to_record(af_el);
    @artist = @audio_file.artist
    @wikiname = @artist.wikiname
    wikihost = "http://en.wikipedia.org"
    @wikiurl = wikihost + "/w/index.php?action=render&title=" + @wikiname;    
    Rails.logger.info("URL: #{@wikiurl}")

    respond_to do |format|
      format.json { render :json => { :wikiurl => @wikiurl, :wikiname => @wikiname } }
    end
  end

  def search
    Rails.logger.info("Search: #{params}")
    @q = params[:q]
    srch = [Artist,Album,AudioFile].select{|c| params[c.to_s.to_sym]}
    srch = [Artist,Album,AudioFile] if srch.empty?
    per_page = 10
    @search = Sunspot.search(*srch) do |s|
      s.order_by(:random) if @q == ""
      s.keywords @q
      
      s.paginate :page => params[:page], :per_page => per_page
    end

    respond_to do |format|
      format.html
    end
  end

  def dosearch
    Rails.logger.info("Search: #{params}")
    @q = params[:q]
    srch = [Artist,Album,AudioFile].select{|c| params[c.to_s.to_sym]}
    srch = [Artist,Album,AudioFile] if srch.empty?
    per_page = 10
    @search = Sunspot.search(*srch) do |s|
      s.order_by(:random) if @q == ""
      s.keywords @q
      
      s.paginate :page => params[:page], :per_page => per_page
    end

    # @search2 = Sunspot.search(AudioFile) do |s|
    #   s.order_by(:random) if @q == ""
    #   s.keywords @q
      
    #   s.facet :artist_id
    #   s.facet :album_id
    #   s.facet :song_id
    # end
    
    respond_to do |format|
      format.js
    end
  end

  def aside
    @q = params[:q]
    @el_id = params[:el_id]
    @recs = elem_id_to_records(@el_id)

    # if @recs.size > 1
    #   @context_rec = filter_rec = @recs.shift
    #   @hsh = artist_album_aside(filter_rec, @recs)
    # else
    #   @context_rec = rec = @recs.shift
    #   @hsh = {}
    #   case rec.class.to_s
    #   when 'Album'
    #     @hsh[rec] = rec.audio_files
    #   when 'AudioFile'
    #     @hsh[rec] = rec.lyric ? [rec.lyric] : []
    #   when 'Artist'
    #     @hsh[rec] = rec.albums.uniq
    #   end
    # end
    if @recs.size > 1
      @context_rec = @recs.shift
    else
      @context_rec = @recs[0]
    end


    respond_to do |format|
      format.html { render 'aside', :layout => 'narrow_layout' }
    end

  end

  def artist_album_aside(artist,albums)
    hsh = {}
    albums.each do |album|
      hsh[album] = []
      afs = album.audio_files.limit_to(artist);
      hsh[album] = afs
    end
    hsh
  end


end
