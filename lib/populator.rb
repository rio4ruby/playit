require 'RMagick'
require 'mp3info'
require 'taglib'
require 'rio'
require 'filemagic'

$:.unshift(File.expand_path("../../lib", __FILE__))

require 'slog'

$stdout.sync = 1

class Populator
  attr_reader :root_dir
  def initialize(root_dir)
    @root_dir = root_dir

  end
  def self.fm
    @@fm ||= FileMagic.open(:mime_type)
  end
  def self.mime_type(filepath)
    fm.file(filepath.to_s)
  end

  class << self
    @@artist_recs = {}
    @@song_recs = {}
    @@album_recs = {}
    @@genre_recs = {}
    @@file_dir_recs = {}

    def rearrange_comma_sep_name(name)
      words = name.split(/\s*,\s*/)
      if words.size == 2
        if words[1].downcase == 'the'
          words.reverse.join(' ')
        else
          if words.any?{ |w| w =~ /\s/ }
            name
          else
            words.reverse.join(' ')
          end
        end
      else
        name
      end
    end

    def to_wikiname(name)
      rearrange_comma_sep_name(name).strip.split(/\s+/).map(&:capitalize).join('_') if name
    end

    def artist_rec(name)
      unless @@artist_recs[name] 
        artist = Artist.find_or_initialize_by_name(name)
        artist.wikiname = to_wikiname(name)
        artist.save!
        @@artist_recs[name] = artist
      end
      @@artist_recs[name]
    end
    def song_rec(name)
      @@song_recs[name] ||= Song.find_or_create_by_name(name)
    end
    def genre_rec(name)
      @@genre_recs[name] ||= Genre.find_or_create_by_name(name)
    end
    def file_dir_rec(name)
      @@file_dir_recs[name] ||= FileDir.find_or_create_by_name(name)
    end
    
    def album_rec(name,dir_name)
      album_dir = file_dir_rec(dir_name)
      # p "album_rec name=#{name} dir_name=#{dir_name} album_dir.id=#{album_dir.id}"
      Album.find_or_create_by_album_dir_id_and_name(album_dir.id,name)
      
      # album = Album.where(:album_dir_id => album_dir.id, :name => name).first
      # unless album
      #   album = Album.create(:album_dir_id => album_dir.id, :name => name)
      # end
      # album
    end

  end

  def topdirs(*topsel)
    topsel.flatten.each do |tdir|
      rio(root_dir).dirs(tdir) do |dir|
        yield dir
      end
    end

  end



  def populate(*args)
    populate_topdirs(*args)
  end


  def populate_topdirs(*topdirs)
    topdirs.flatten.each do |tdir|
      rio(root_dir).dirs(tdir) do |dir|
        puts "#{dir}"
        populate_dirs(dir)
      end
    end
  end
  def populate_dirs(dval)
    dir = rio(dval)
    populate_dir(dir)
    dir.dirs do |d|
      populate_dirs(d)
    end
    combine_same_album_dirs(dir)
  end

  def combine_same_album_dirs(dir)
    albums_byname = {}
    dir.dirs do |d|
      file_dir = FileDir.find_by_name(d.to_s)
      albums = file_dir.albums.uniq
      if albums.size == 1
        albums_byname[albums.first.name] ||= []
        albums_byname[albums.first.name] << albums.first
      end
    end
    albums_byname.each do |name,albums|
      if albums.size > 1
        albums_artists = albums.map(&:album_artist).uniq
        if albums_artists.size == 1
          albums_image_files = albums.map(&:album_image_file).uniq
          new_file_dir = FileDir.find_or_create_by_name(dir.to_s)
          new_album = new_file_dir.build_album(:name => name)
          new_album.album_artist_id = albums_artists.first.id
          imgfile = albums_image_files.first
          new_album.album_image_file_id = imgfile.id if imgfile
          new_album.save!

          albums.each do |alb|
            alb.audio_files.each do |af|
              af.album_id = new_album.id
              af.save!
            end
            alb.destroy
          end
        end
      end
    end
  end


  def populate_dir(d)
    dir = rio(d)
    process_mp3_files(dir);
    process_image_files(dir);
    update_album_ids(dir)
  end

  def update_album_ids(dir)
    file_dir = FileDir.find_or_create_by_name(dir.to_s)
    albums = file_dir.albums.uniq
    albums.each do |album|
      album = Album.find(album.id)
      album_artists = album.artists.uniq
      if album_artists.size == 1
        album.album_artist = album_artists.first
        album.save!
      else
        album.album_artist = nil
        album.save!
      end
      image_file = album.image_files.midsize.uniq.first
      album.album_image_file = image_file
      album.save!
    end
    

  end
  
  
  def populate_mp3_file(f)
    file = rio(f)
    af = Af.new(file)
    af.populate
  end

  def process_mp3_files(dir)
    puts dir
    afs = []
    # rio(dir).files('*.[mM][Pp]3') do |el|
    rio(dir).files('*.m4a') do |el|
      puts "   #{el}"
      af = Af.new(el)
      af.populate
      afs << af
    end
    albums = afs.map(&:afinfo).map(&:af).map(&:album).uniq
  end

  class Af
    attr_reader :file, :afinfo
    def initialize(file)
      @file = rio(file)
      @afinfo = nil
    end
    def populated?
      if file_dir = FileDir.find_by_name(file.dirname.to_s)
        if AudioFile.find_by_file_dir_id_and_filename(file_dir.id, file.filename.to_s)
          return true
        end
      end
      return false
    end

    def populate
      ext = file.extname
      case ext
      when '.m4a'
        @afinfo = Populator::AfInfoM4a.new(file);
        af = @afinfo.populate
      when '.mp3'
        # unless populated?
        unless false
          begin
            @afinfo = Populator::AfInfoMp3.new(file);
            if af = @afinfo.populate
              aftags = Populator::AfTags.new(file,af,@afinfo.afinfo)
              aftags.populate
            end
          rescue Exception => e
            Slog.err("Af.populate failed: #{e.to_s.sub('%','%%')}")
          end
        end
      end
    end
  end














  class AfInfo
    attr_reader :file, :afinfo, :af
    def initialize(file)
      @file = rio(file)
      @afinfo = nil
      @af = nil
    end

    def populate
      begin
        data = self.read
        attr = self.create_afattr(data)

        @af = self.save(attr)

        Slog.info("#{@af.artist.name} - #{@af.tracknum} - #{@af.song.name} - #{@af.genre.name}")
        @af
      rescue Exception => e
        Slog.err("Problem populating #{file}: #{e}")
        raise
      end
    end


    def create_afattr(rec)
      attr = {
        :file_modified_time => rec[:file_modified_time],
        :file_size => rec[:file_size],
        :file_dir => Populator.file_dir_rec(rec[:file_dir_name]),
        
        :artist => Populator.artist_rec(rec[:artist_name]),
        :song => Populator.song_rec(rec[:song_name]),
        :genre => Populator.genre_rec(rec[:genre_name]),
        :album => Populator.album_rec(rec[:album_name],rec[:album_dir]),
        
        :tracknum => rec[:tracknum],
        :bitrate => rec[:bitrate],
        :samplerate => rec[:samplerate],
        :length => rec[:length],
        :layer => rec[:layer],
        :mpeg_version => rec[:mpeg_version],
        :vbr => rec[:vbr],
        :audio_start => rec[:audio_start],
        :audio_length => rec[:audio_length],
        :mime_type => rec[:mime_type],
      }
      attr
    end
    
    def save(attr)
      begin
        
        @af = AudioFile.find_or_initialize_by_file_dir_id_and_filename(attr[:file_dir].id, file.filename.to_s)
        
        @af.attributes = attr
        @af.save!

        @af
      rescue ActiveRecord::MultiparameterAssignmentErrors => e
        Slog.err("Errors saving #{file}")
        e.errors.each do |aae|
          Slog.err("    #{aae}")
        end
        raise
      rescue ActiveRecord::AttributeAssignmentError => e
        Slog.err("Error saving #{file}   #{e}")
        raise
      rescue ActiveRecord::ActiveRecordError => e
        Slog.err("ActiveRecordError #{e}       ATTR=#{attr}")
        raise
      end
    end
  end # class AfInfo

  class AfInfoM4a < AfInfo
    
    def read
      
      TagLib::FileRef.open(file.to_s) do |fileref|
        tag = fileref.tag
        
        properties = fileref.audio_properties
        
        rec = {
          :file_modified_time => file.mtime,
          :file_size => file.size,
          :file_dir_name => file.dirname.to_s,
          
          :artist_name => tag.artist,
          :album_name => tag.album,
          :song_name => tag.title,
          :genre_name => tag.genre,
          :album_dir => file.dirname.to_s,
          :year => tag.year,
          
          :tracknum => (tag.track.blank?) ? nil : tag.track.to_i,
          :bitrate => properties.bitrate,
          :samplerate => properties.sample_rate,
          :length => properties.length,
        }
        rec[:mime_type] = Populator.mime_type(file)
        rec
      end  # File is automatically closed at block end
    end
  end

  class AfInfoMp3 < AfInfo

    def read
      begin
        Mp3Info.open(file.to_s,:encoding => 'utf-8') do |mp3|
          @afinfo = mp3
          rec = {
            :file_modified_time => file.mtime,
            :file_size => file.size,
            :file_dir_name => file.dirname.to_s,
            
            :artist_name => mp3.tag.artist,
            :album_name => mp3.tag.album,
            :song_name => mp3.tag.title,
            :genre_name => mp3.tag.genre_s,
            :album_dir => file.dirname.to_s,

            :tracknum => (mp3.tag.tracknum.blank?) ? nil : mp3.tag.tracknum.to_i,
            :bitrate => mp3.bitrate,
            :samplerate => mp3.samplerate,
            :length => mp3.length,
            :layer => mp3.layer,
            :mpeg_version => mp3.mpeg_version,
            :vbr => mp3.vbr,
          }
          rec[:audio_start],rec[:audio_length] = mp3.audio_content
          rec[:mime_type] = Populator.mime_type(file)
          rec
        end
      rescue [ Mp3Info, Mp3InfoError, Mp3InfoInternalError ] => e
        Slog.err("Mp3Info problem: #{e}")
        raise e
      end
    end


  end





















  class AfTags
    attr_reader :file, :af, :mp3info
    def initialize(file,af,mp3info)
      @file = file
      @af = af
      @mp3info = mp3info
    end

    def populate
      begin
        @af.audio_files_tags.delete_all
        data = self.read
        self.save(data)
        @af
      rescue Exception => e
        Slog.err("Problem adding tags to #{file}: #{e}")
        raise
      end
    end
    def read
      tags = {}
      begin
        @mp3info.tag2.keys.each do |tag|
          unless tag.blank?
            val = @mp3info.tag2[tag]
            unless val.blank?
              tags[tag] = val
            end
          end
        end
      rescue ID3v2Error
        #Slog.err("Problem reading tags: succefully read #{tags.keys.inspect}")
      end
      return tags
    end
    def save(tags)
      tags_added = []
      tags.each do |tag,val|
        begin
          tag_rec = Tag.find_or_initialize_by_name_and_value(tag,val)
          tag_rec.audio_files << @af
          tag_rec.save!
          tags_added << tag
        rescue ActiveRecord::ActiveRecordError => e
          #Slog.err("Problem adding tag '#{tag}' from '#{file}': #{e}")
        end
      end
      tags_added
    end
  end # class AfTags



  def _db_mod_time(rec)
    rec.file_modified_time.to_time.round
  end
  def _fs_mod_time(file)
    file.mtime.utc.round
  end





  def image_units_string(img)
    case img.units
    when Magick::PixelsPerInchResolution then "inch"
    when Magick::PixelsPerCentimeterResolution then "centimeter"
    else nil
    end
  end
  def process_image_files(dir)
    file_dir = FileDir.find_or_create_by_name(dir.to_s)
    rio(dir).files('*.[Jj][Pp][Gg]') do |el|
      begin
        fp = rio(el)
        image_file = ImageFile.find_by_file_dir_id_and_filename(file_dir.id,fp.filename.to_s)
        unless image_file
          begin
            img = Magick::Image::read(el.to_s).first
            rec = ImageFile.new(:file_dir => file_dir, :filename => fp.filename.to_s)
            rec.file_modified_time = el.mtime
            rec.attributes = {
              :format => img.format,
              :columns => img.columns,
              :rows => img.rows,
              :depth => img.depth,
              :number_colors => img.number_colors,
              :filesize => img.filesize,
              :x_resolution => img.x_resolution,
              :y_resolution => img.y_resolution,
              :units => image_units_string(img)
            }
            rec[:mime_type] = Populator.mime_type(fp)
            rec.save!
            puts "\tIMAGE SAVED: #{fp} "
          rescue Magick::ImageMagickError => e
            #puts "Skipping: #{e}"
            Slog.err "Skipping: #{e}"
          end
        else
        end
      end
    end
  end
  

end

__END__
