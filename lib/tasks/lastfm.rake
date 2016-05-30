# encoding: UTF-8
BEGIN {
  Encoding.default_internal = "UTF-8"
  Encoding.default_external = "UTF-8"
}

require 'cgi'
require 'open-uri'
require 'rio'
require 'xmlsimple'
require 'lastfm'

$stdout.sync = true

def escape_param(str)
  CGI.escape(str.gsub(' ','_'))
end

def lyrics_url(astr,sstr)
  "http://lyrics.wikia.com/api.php?func=getSong&artist=#{astr}&song=#{sstr}&fmt=xml"
end
def artist_url(astr)
  "http://lyrics.wikia.com/api.php?func=getArtist&artist=#{astr}&fmt=xml&fixXML"
end

#Unfortunately, we are not licensed to display the full lyrics for this
#song at the moment. Hopefully we will be able to in the future. Until
#then, how about a random page?

#[I want to edit metadata]
def filter_txt(txt)
  return txt.gsub(/\n/,' ')
end
def format_txt(txt)
  txt.sub(/\A\s+/,'').gsub(/^ +/,'').gsub(/\n\n\n+/,"\n\n")
end
def format_txt2html(txt)
  t = txt.sub(/\A\s+/,'').gsub(/^ +/,'').gsub(/ +$/,'')
  t2 = t.gsub(/^(.+)\n/,'\1<br/>' + "\n")
  paras = t2.split(/\n\n+/)
  paras = paras.map{|pp| %{<p>\n#{pp}\n</p>\n}}
  paras.join
end
namespace :lastfm do
  task :getalbumcovers, [:topdir, :needs] => [:environment] do |t,args|
    lfm = LastFm.new
    cnt = 0;
    rio('/srv/data/lastfm2/album').dirs do |tdir|
      begin
        tdir.dirs do |dir|
          dir.files('album.xml') do |file|
            cnt += 1
            print "#{cnt}"
            xml = XmlSimple.xml_in(file.to_s)
            if xml
              albumlist = xml['album']
              if albumlist
                album = albumlist[0]
                if album
                  coverdir = [dir,'cover'].join('/')
                  ::FileUtils.mkpath(coverdir.to_s) unless ::File.exist?(coverdir.to_s)
                  xartist = album['artist'].first
                  xalbum = album['name'].first
                  print "\t#{xartist}\t#{xalbum}"
                  image_urls = {}
                  album['image'].each do |h|
                    next unless h['content']
                    ifile = rio(h['content'])
                    ofile = rio(coverdir,h['size'] + ifile.extname)
                    image_urls[ifile] ||= []
                    image_urls[ifile] <<  ofile
                  end
                  cnt_read = 0
                  image_urls.each do |ifile,ofiles|
                    if ofiles.any?{ |f| ! f.exist? }
                      cnt_read += 1
                      img_data = rio(ifile).binmode.contents
                      ofiles.each do |of|
                        unless of.exist? 
                          puts "\t\t => #{of}"
                          IO::binwrite(of.to_s,img_data)
                        end
                      end
                    end
                  end
                  sleep(0.2) if cnt_read > 0
                end
              end
            end
            puts
          end
        end
      rescue Exception => e
        puts "\nError with #{file}: #{e}\n"
      end
    end
  end
  task :getalbuminfo2, [:topdir, :needs] => [:environment] do |t,args|

    lfm = LastFm.new
    ycnt = 0
    ncnt = 0
    Artist.all.each do |artist|
      artist.albums.each do |album|
        album_name = album.name
        artist_name = artist.name
        ofile = lfm.oxmlname(album_name, artist_name);
        if ::File.exist?(ofile)
          ycnt += 1
        else
          ncnt += 1
          ans =  lfm.save_album_data(album_name,artist_name)
          puts "\n\t#{ans}\t#{artist_name}\t#{album_name}"
          sleep 0.2
        end
        print("\r#{ycnt}\t#{ncnt}")
        # unless lastfm.process_album(album_name,artist_name)
        #   sleep 1
        # end
      end
    end
    puts
    # Artist.where(["artists.name like ?", 'A%']).all.each do |artist|
    # # Artist.where(:name => 'Warren Zevon').each do |artist|
    #   artist_name = artist.name
    #   artist.albums.uniq.each do |album|
    #     album_name = album.name
    #     print "#{artist_name}\t#{album_name}"
    #     path = lastfm.album_getinfo_path(album_name,artist_name)
    #     puts "\t#{path}"
    #     sleep 1
    #  end
    # end
    
  end
  task :getalbuminfo, [:topdir, :needs] => [:environment] do |t,args|

    lfm = LastFm.new
    ycnt = 0
    ncnt = 0
    Album.all.each do |album|
      artist = album.album_artist
      next unless artist
      album_name = album.name
      artist_name = artist.name
      ofile = lfm.oxmlname(album_name, artist_name);
      if ::File.exist?(ofile)
        ycnt += 1
      else
        ncnt += 1
        ans =  lfm.save_album_data(album_name,artist_name)
        puts "\n\t#{ans}\t#{artist_name}\t#{album_name}"
        sleep 0.2
      end
      print("\r#{ycnt}\t#{ncnt}")
      # unless lastfm.process_album(album_name,artist_name)
      #   sleep 1
      # end
    end
    puts
    # Artist.where(["artists.name like ?", 'A%']).all.each do |artist|
    # # Artist.where(:name => 'Warren Zevon').each do |artist|
    #   artist_name = artist.name
    #   artist.albums.uniq.each do |album|
    #     album_name = album.name
    #     print "#{artist_name}\t#{album_name}"
    #     path = lastfm.album_getinfo_path(album_name,artist_name)
    #     puts "\t#{path}"
    #     sleep 1
    #  end
    # end
    
  end
end
