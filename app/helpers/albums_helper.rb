module AlbumsHelper

  def albumart_url(album,size = 'medium')
    artist_name = album.album_artist_name
    if artist_name
      album_name = album.name
      # "http://albumart-server.kitatdot.net/#{artist_name}/#{album_name}/cover/#{size}" 
    else
      # "/assets/64x64/devices/media-optical-audio_mount.png"
      artist_name = '_DEFAULT_'
      album_name = '_DEFAULT_'
    end

    "http://media.kitatdot.net/albumart/#{URI.encode(artist_name)}/#{URI.encode(album_name)}/cover/#{size}" 
  end


end
