require 'filemagic'
class AlbumsController < InheritedResources::Base
  layout Proc.new { |controller| controller.request.xhr? ? false : 'appfixed' }

  def index
    @q = params[:q]
    per_page = 10
    @q ||= ""
    @search = Sunspot.search(Album) do |s|
      s.keywords @q
      s.paginate :page => params[:page], :per_page => per_page
    end
    @albums = @search.results

  end

  def show
    @q = params[:q]
    @album = Album.find(params[:id].to_i)
    per_page = 10
    @q ||= ""
    @search = Sunspot.search(Album) do |s|
      s.keywords @q
      s.with :id, params[:id].to_i
      s.paginate :page => params[:page], :per_page => per_page
    end
    @albums = @search.results
    @tab = params[:tab] || 'tab-album'
  end

  def search
    @q = params[:q]
    per_page = 10
    if @q
      @search = Sunspot.search(Album) do |s|
        s.keywords @q
        
        s.paginate :page => params[:page], :per_page => per_page
      end
      @albums = @search.results
    else
      @albums = Album.page(params[:page]).per(per_page)
    end
    respond_to do |format|
      format.html{ render 'index' }
    end
  end

  def add_to_playing
    @id = params[:id]
    list_node = current_user.list_heads.playing.first.list_node
    new_node = Album.find(@id).create_list_node_all(list_node)
    @node_id = new_node.id
    subtree = ListNode.includes(:listable).ordered.subtree_of(@node_id).all
    @nodetree = NodeTree.new(subtree)

    respond_to do |format|
      format.js
    end
  end

  def add
    @artist_id = params[:artist_id]
    @id = params[:album_id] || params[:id]

    list_node = current_user.list_heads.playing.first.list_node
    artists = @artist_id ? [Artist.find(@artist_id.to_i)] : []
    new_node = Album.find(@id).create_list_node_all(list_node,artists)

    @node_id = new_node.id
    subtree = ListNode.includes(:listable).ordered.subtree_of(@node_id).all
    @nodetree = NodeTree.new(subtree)

    respond_to do |format|
      format.js
    end
  end


  def lookup
    Rails.logger.info("Search: #{params}")
    @q = params[:q]
    per_page = 10
    @search = Sunspot.search(Album) do |s|
      s.order_by(:random) if @q == ""
      s.keywords @q
      s.paginate :page => params[:page], :per_page => per_page
    end
    names = @search.hits.map{|hit| hit.stored(:name) }.flatten
    Rails.logger.info("NAMES: #{names}")
    respond_to do |format|
      format.json { render :json => { :results => names } }
    end
  end

  def altimg(album,size = 'medium')
    artist = album.album_artist
    if artist
      album_name = album.name
      artist_name = artist.name
      # altdir = "/srv/data/lastfm/album/#{URI.encode(artist_name)}/#{URI.encode(album_name)}/cover"
      # altdir = "/mnt/files/lastfm/album/#{URI.encode(artist_name)}/#{URI.encode(album_name)}/cover"
      altdir = "/srv/data/lastfm2/album/#{artist_name}/#{album_name}/cover"
      imgfilebase = altdir + '/' + size + '.'
      ['jpg','png'].each do |ext|
        imgfile = imgfilebase + ext
        if ::File.exist?(imgfile)
          return imgfile
        end
      end
    end
    return nil
  end


  def image
    album = Album.includes(:album_artist).find(params[:id])
    sz = params[:sz]
    filepath = altimg(album,sz || 'medium')
    unless filepath
      image_file = album.album_image_file
      if image_file
        filepath = image_file.filepath
      else
        filepath = "app/assets/images/64x64/devices/media-optical-audio_mount.png"
      end
    end

    mime_type = image_file.mime_type if image_file
    Rails.logger.info("filepath = " + filepath.inspect)
    mime_type ||= FileMagic.open(:mime_type).file(filepath)

    response.headers['Cache-Control'] = "public, max-age=#{7.days.to_i}"
    response.headers['Content-Type'] = mime_type
    response.headers['Content-Disposition'] = 'inline'
    content = open(filepath,'rb').read
    #response.headers['Content-Length'] = %{"#{content.size}"}
    response.headers['Content-Length'] = content.size.to_s
 #   response.headers['Content-Type'] = @file.content_type
 #   response.headers['Content-Disposition'] = "attachment; size=\"#{@file.file_size}\"; filename=\"#{@file.original_filename}\""
    
    render :text => content
    
  end


end
