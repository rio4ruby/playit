# encoding: UTF-8
BEGIN {
  Encoding.default_internal = "UTF-8"
  Encoding.default_external = "UTF-8"
}

require 'cgi'
require 'open-uri'
require 'rio'
require 'xmlsimple'
require "nokogiri"


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
$stdout.sync = 1
module MyTasks
  def do_aatree_task
    treedir = rio('/srv/data/aatree').mkdir;
  end
end


namespace :development do
  DATAROOT = '/srv/data/lyrics2'
  PAGESDIR = rio(DATAROOT,'pages')
  HTMLDIR = rio(DATAROOT,'html')
  TEXTDIR = rio(DATAROOT,'text')

  task :makeaatree, [:topdir, :needs] => [:environment] do |t,args|
    treedir = rio('/srv/data/aatree').mkdir;
    puts "mkdir OK" if treedir.exist?
    treedir.rmdir
    puts "rmdir OK" unless treedir.exist?

  end

  task :grablyrics, [:topdir, :needs] => [:environment] do |t,args|
    fcount = 0
    errcount = 0
    AudioFile.includes(:artist,:song).all.each do |af|
      artist_name = af.artist_name.strip
      # next unless artist_name =~ /^David/i
      song_name = af.song_name.strip
      song_part = song_name.downcase.gsub(/[^a-z0-9 ]/,'').gsub(' ','-').squeeze('-')
      artist_part = artist_name.downcase.gsub(/[^a-z0-9 ]/,'').gsub(' ','-').squeeze('-')
      next if song_part.blank? || artist_part.blank?
      filename = [song_part,artist_part].join('-lyrics-') + ".html"
      url = 'http://www.lyrics.com/' + filename
      destfile = rio(PAGESDIR,filename)
      unless destfile.exist?
        begin
          puts "#{song_name} - #{artist_name} => #{url}"
          rio(url) > destfile
          fcount += 1
        rescue Exception => e
          p e
          errcount += 1
          raise if errcount > 3
        end
      else
        print "."
      end
      #break if fcount > 10
    end
  end

  task :striplyrics, [:topdir, :needs] => [:environment] do |t,args|
    fcount = 0
    rio(PAGESDIR).files('*.html') do |pfile|
      destfile = rio(HTMLDIR,pfile.filename)
      if destfile.exist?
        print "."
        next
      end
      m1 = Regexp.escape('<!-- CURRENT LYRIC -->')
      m2 = Regexp.escape('<!-- LYRIC REVISION -->')
      
      begin
        contents = pfile.contents
        if contents =~ /#{m1}(.+)#{m2}/m
          desthtml = $1.gsub("\r",'')

          doc = Nokogiri::XML(desthtml,&:noblanks)
          
          sbmtnode = doc.css('div#lyric_space > p > a').first
          
          next if sbmtnode && sbmtnode.inner_text == "Submit Lyrics"
          print "\n#{destfile}"
          
          
          doc.css('div.thumbs').remove
          doc.css('div.PRINTONLY').remove
          doc.css('div#lyric_correction_paragraph').remove
          
          rio(destfile) < doc.to_xml(:indent => 2, :encoding => 'UTF-8')
          # destio = ::File.open(destfile.to_s,'w')
          # p destio
          # doc.write_xml_to(destio, :indent => 2, :encoding => 'UTF-8')
          # destio.close
        end
      rescue Exception => e
        puts e
      end
    end
  end

  task :textlyrics, [:topdir, :needs] => [:environment] do |t,args|
    fcount = 0
    rio(HTMLDIR).files('*.html') do |htmlfile|
      destfile = rio(TEXTDIR,htmlfile.basename + '.txt')
      print destfile

      srcio = ::File.open(htmlfile.to_s)
      doc = Nokogiri::XML(srcio,&:noblanks)
      
      lyrnode = doc.css('div#lyrics').first || doc.css('div#lyric_space').first

      text = lyrnode ? lyrnode.inner_text : ""

      if text.sub!(/---Lyrics\s+(submitted|powered)\s+by\s+\w+\.?/, '')
        print " ATTR REMOVED"
      end
      lines = text.strip.split("\n").map{|l| l.strip + "\n" }
      puts " #{lines.size} lines"

      if lines.size > 0
        destfile < lines
        fcount += 1
      end
      #break if fcount > 10
    end
  end



end


__END__



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
