# encoding: UTF-8
BEGIN {
  Encoding.default_internal = "UTF-8"
  Encoding.default_external = "UTF-8"
}

require 'cgi'
require 'open-uri'
require 'rio'
require 'xmlsimple'

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

def lyric_basename(s_name,a_name)
  artist_name = a_name.strip
  # next unless artist_name =~ /^David/i
  song_name = s_name.strip
  
  song_part = song_name.downcase.gsub(/[^a-z0-9 ]/,'').gsub(' ','-').squeeze('-')
  artist_part = artist_name.downcase.gsub(/[^a-z0-9 ]/,'').gsub(' ','-').squeeze('-')

  [song_part,artist_part].join('-lyrics-') unless song_part.blank? || artist_part.blank?

end
$stdout.sync = 1

namespace :development do



  task :addlyricstodb, [:topdir, :needs] => [:environment] do |t,args|
    DATAROOT = '/srv/data/lyrics2'
    TXTDIR = rio(DATAROOT,'text')

    Artist.all.each do |artist|
    # Artist.where(:name => 'David Bowie').each do |artist|
      artist.songs.uniq.each do |song|
        bn = lyric_basename(song.name,artist.name)
        if bn
          lyric_txt_file = rio(TXTDIR,bn + '.txt')
          if lyric_txt_file.exist?
            lyric_txt = lyric_txt_file.contents
            olyric = Lyric.find_by_song_id_and_artist_id(song.id,artist.id)
            if olyric
              olyric_txt = olyric.text
              if olyric_txt =~ /I want to edit metadata/
                print "\nReplace Partial #{lyric_txt_file} (#{lyric_txt.size}) "
                olyric.text = lyric_txt
                olyric.save!
              else
                if olyric_txt.size < 8 || lyric_txt.size/olyric_txt.size > 1.5
                  print "\nReplace Complete #{lyric_txt_file} (#{lyric_txt.size}) "
                  olyric.text = lyric_txt
                  olyric.save!
                elsif olyric_txt.include?('---Lyrics ')
                  print "\nReplace Complete ATTR #{lyric_txt_file} (#{lyric_txt.size}) "
                  olyric.text = lyric_txt
                  olyric.save!
                else
                  # puts "Keep Original #{lyric_txt_file} (#{lyric_txt.size}) "
                  print "."
                end
              end
            else
              print "\nAdd new lyrics #{lyric_txt_file} (#{lyric_txt.size}) "

              lyr = Lyric.create(:text => lyric_txt,
                                 :artist_id => artist.id,
                                 :song_id => song.id)
            end


          end


        end
      end
      
    end
  end





  task :addlyricstodb0, [:topdir, :needs] => [:environment] do |t,args|
    DATAROOT = '/srv/data/lyrics'
    XMLDIR = rio(DATAROOT,'xml')
    PAGEDIR = rio(DATAROOT,'pages')
    TXTDIR = rio(DATAROOT,'txt')

    Artist.all.each do |artist|
    # Artist.where(:name => 'Warren Zevon').each do |artist|

      astr = escape_param(artist.name)

      artist_dir = rio(XMLDIR,astr)

      if artist_dir.dir?
        artist.songs.each do |song|

          sstr = escape_param(song.name)
          file = rio(artist_dir,sstr + ".xml")
          if file.file?
            
            lfile = rio(file)
            lfile.extname = '.txt'
            lfile.dirname = TXTDIR/file.dirname.filename
            lfile2 = rio(lfile.dirname,URI.encode(URI.encode(file.filename.to_s)))
            lfile2.extname = '.txt'
            # puts "#{lfile2.exist?}\t#{lfile2}","#{lfile.exist?}\t#{lfile}"
            lfile = lfile2 unless lfile.exist?

            if lfile.file?
              lyr = Lyric.find_by_artist_id_and_song_id(artist.id,song.id)
              if lyr
                txt = lfile.contents
                if txt && txt != 'Not found'
                  lyr.text = format_txt(txt)
                  lyr.save!
                  puts "#{lyr.artist.name} #{lyr.song.name}"
                end
              else
                txt = lfile.contents
                if txt && txt != 'Not found'
                  xml = XmlSimple.xml_in(file.to_s, { 'ForceArray' => false, :KeyToSymbol => true })
                  lyr = Lyric.create(:l_artist => xml[:artist],
                                     :l_song => xml[:song],
                                     :text => txt,
                                     :l_url => xml[:url],
                                     :artist_id => artist.id,
                                     :song_id => song.id)
                  
                  puts "#{lyr.artist.name} #{lyr.song.name}"
                end
              end
            end
          end
        end
      end
      
    end
  end




end
