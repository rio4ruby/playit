# encoding: UTF-8
BEGIN {
  Encoding.default_internal = "UTF-8"
  Encoding.default_external = "UTF-8"
}

require 'rubygems'
require 'net/http'
require 'cgi'
require 'xmlsimple'
require 'rio'
require 'fileutils'

# key from API documentation

class LastFm
  API_KEY = "b25b959554ed76058ac220b7b2e0a026" 
  HOST = "ws.audioscrobbler.com"
  OROOT = '/srv/data/lastfm2'
  attr_reader :root_dir
  def initialize
    @root_dir = rio(OROOT)
  end

  def album_getinfo_path(album,artist)
    artist = URI.encode(artist)
    album = URI.encode(album)
    "/2.0/?method=album.getinfo&api_key=#{API_KEY}&artist=#{artist}&album=#{album}&autocorrect=1"
  end
  def getinfo(path)
    Net::HTTP.get(HOST, path)
  end

  def album_info(album,artist)
    getinfo(album_getinfo_path(album,artist))
  end

  def album_info_xml(album,artist)
    data = album_info(album,artist)
    xml = XmlSimple.xml_in(data)
    return xml if xml['status'] == 'ok'
  end
  def data2xml(data)
    xml = XmlSimple.xml_in(data)
    return xml if xml['status'] == 'ok'
  end
  def odirname(album,artist)
    [root_dir,'album',artist,album].join('/')
  end
  def odir(album,artist)
    dirname = odirname(album,artist)
    unless File.exist?(dirname)
      ::FileUtils.mkpath(dirname)
    end
    dirname
  end
               
  def oxmlname(album,artist)
    opath = [root_dir,'album',artist,album].join('/')
    [opath,'album.xml'].join('/')
  end
  def save_album_data(album,artist)
    ofilename = oxmlname(album,artist)
    return if ::File.exist?(ofilename)
    data = album_info(album,artist)
    ofile = [odir(album,artist),'album.xml'].join('/')
    return IO::binwrite(ofile.to_s, data)
  end
  def process_album(album,artist)
    path = album_getinfo_path(album,artist)
    opath = [root_dir,'album',artist,album].join('/')
    puts opath
    return true if File.exist?(opath)

    data = album_info(album,artist)
    xml = data2xml(data)
    return false unless xml
    album = xml['album'][0]
    xartist = album['artist'].first
    xalbum = album['name'].first

    # odir1 = rio(root_dir,'album',URI.encode(xartist),URI.encode(xalbum))
    ::FileUtils.mkpath(opath)
    return false if File.exist?(opath)
    coverdir = [opath,'cover'].join('/')
    ::FileUtils.mkpath(coverdir.to_s)
    ofile1 = [opath,'album.xml'].join('/')
    IO::binwrite(ofile1.to_s, data)
    puts ofile1
    album['image'].each do |h|
      next unless h['content']
      rmt_img = rio(h['content']).binmode
      lcl_img = rio(coverdir,h['size'] + rmt_img.extname)
      puts "    #{rmt_img} => #{lcl_img}"

      cont = rmt_img.contents
      IO::binwrite(lcl_img.to_s, cont);
      # lcl_img.print(cont)
    end
    
    return false;
  end
end

__END__
artist = 'David Bowie'
album = 'Scary Monsters'
lastfm = LastFm.new
lastfm.process_album(album,artist)

data = lastfm.album_info(album,artist)
xml = lastfm.data2xml(data)
if xml
  album = xml['album'][0]
  artist = album['artist'].first
  name = album['name'].first
  puts data
  puts "ARTIST: #{artist} ALBUM: #{name}"
end




__END__
 
def fetch_cover(artist, album)
	artist = CGI.escape(artist)
	album = CGI.escape(album)
 
	path = "/2.0/?method=album.getinfo&api_key=#{$lastfm_key}&artist=#{artist}&album=#{album}"
	data = Net::HTTP.get($lastfm_host, path)
	xml = XmlSimple.xml_in(data)
	if xml['status'] == 'ok' then		
          album = xml['album'][0]
 
		cover = {
			:small => album['image'][1]['content'],
			:medium => album['image'][2]['content'],
			:big => album['image'][3]['content']
		}
 
		return cover
	end
 
	return nil
end
 
artist = 'David Bowie'
album = 'Scary Monsters'
cover = fetch_cover(artist, album)
#cover = {:small=>"http://userserve-ak.last.fm/serve/64s/76320268.png", :medium=>"http://userserve-ak.last.fm/serve/174s/76320268.png", :big=>"http://userserve-ak.last.fm/serve/300x300/76320268.png"}
if cover
  cover.each do |szsym,imgurl|
    nm = rio("#{artist}-#{album}-#{szsym}")
    rimg = rio(imgurl)
    nm.extname = rimg.extname
    puts "#{rimg} => #{nm}"
    rimg > nm
  end
end

