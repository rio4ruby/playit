require 'RMagick'
require 'mp3info'
require 'taglib'
require 'rio'
require 'filemagic'

$:.unshift(File.expand_path("../../lib", __FILE__))

require 'slog'

$stdout.sync = 1

class Updater
  attr_reader :rootdir
  def initialize(rootdir)
    @rootdir = rio(rootdir)
    @file_dir_ids = {}
  end

  def file_dir_id(name)
    @file_dir_ids[name] ||= FileDir.find_or_create_by_name(name).id
  end
  def dumpinfo(info)
    "#{info[:mtime]}\t#{info[:size]}\t#{info[:filename]} [#{info[:dirname]}]"
  end
  def checkdiff(f_info,db_info)
    if f_info != db_info
      puts "\nDb Record differs"
      f_info.keys.each do |k|
        if f_info[k] != db_info[k]
          print "  #{k}: #{f_info[k].inspect}"
          print (f_info[k] == db_info[k] ? ' == ' : ' != ')
          puts "#{db_info[k].inspect}"
        end
      end
      return true
    else
      return false
    end
  end
  def file_info(file)
    {
      :filename => file.filename.to_s,
      :mtime => file.mtime.utc.round,
      :size => file.size
    }
  end
  def db_info(af)
    {
      :mtime => af.file_modified_time.utc.round,
      :size => af.file_size,
      :filename => af.filename,
    }
  end
  def add_file_to_db(file)
    ext = file.extname
    case ext
    when /\.m4a/i
      afinfo = Populator::AfInfoM4a.new(file);
      afinfo.populate
    when /\.mp3/i
      afinfo = Populator::AfInfoMp3.new(file);
      if af = afinfo.populate
        aftags = Populator::AfTags.new(file,af,afinfo.afinfo)
        aftags.populate
      end
    end
  end
  def check_db
    root_fd = FileDir.find_or_create_by_name(rootdir.to_s)
    file_dirs = FileDir.includes(:audio_files).subtree_of(root_fd).all
    fd_cnt = file_dirs.size
    puts
    dir_cnt = 0
    file_cnt = 0
    fmiss_cnt = 0
    file_dirs.each do |file_dir|
      dir = rio(file_dir.name)
      if dir.exist?
        dir_cnt += 1
        file_dir.audio_files.each do |af|
          file = rio(file_dir.name,af.filename)
          if file.exist?
            file_cnt += 1
          else
            fmiss_cnt += 1
            print "\nFile #{file} does not exist on filesystem. destroying..."
            af.destroy()
            puts "done"
          end
        end
      else
        print "\nDir #{file_dir.name} does not exist on filesystem. destroying..."
        file_dir.destroy()
        puts "done"
      end
      printf("\r%d/%d %d/%d",dir_cnt,fd_cnt,fmiss_cnt,file_cnt)
    end
    printf("\r%d/%d %d/%d\n",dir_cnt,fd_cnt,fmiss_cnt,file_cnt)

  end


  def run(dirsel)
    puts rootdir
    rio(rootdir).dirs(dirsel) do |dir|
      $stdout.print(dir.filename.to_s)

      root_fd = ::FileDir.find_or_create_by_name(dir.to_s)
      file_dirs = FileDir.includes(:audio_files).subtree_of(root_fd).all
      fd_map = Hash[ file_dirs.map{|d| [d.name,d]} ]
      
      dir.all.dirs do |subdir|
        files = subdir.files['*.[Mm][Pp][3]','*.[Mm]4[aA]']
        #files = subdir.files['*.m4a']
        unless files.empty?
          file_dir = fd_map[subdir.to_s]
          if file_dir
            af_map = Hash[ file_dir.audio_files.map{|a| [a.filename,a]} ]
            files.each do |file|
              $stdout.print('.')
              f_info = file_info(file)
              af = af_map[file.filename.to_s]
              if af
                db_info = db_info(af)
                if checkdiff(f_info,db_info)
                  add_file_to_db(file)
                end
              else
                print "\nDb Record not found for #{dumpinfo(f_info)}. Updating..."
                add_file_to_db(file)
                puts "done."
              end
            end
          else
            print "\nDb Dir not found for #{subdir.to_s}. Updating..."
            pop = Populator.new('/srv/mp3')
            pop.populate_dirs(subdir.to_s)
            puts "done."
          end
        end
      end
      $stdout.puts
    end
  end
end



__END__
class Mp3NodeException < StandardError
end
 


class Mp3Node
  attr_reader :file, :tag, :prop, :rec
  def initialize(file)
    @file = file
    @fileref = nil
    @tag = {}
    @prop = {}
    @rec = self.parse
  end
  def parse
    begin
      Mp3Info.open(file.to_s,:encoding => 'utf-8') do |mp3|
        @mp3info = mp3
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
          # :tracknum => mp3.tag.tracknum,
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
    rescue Mp3InfoError => e
      # $stderr.puts("Mp3InfoError problem: #{e}")
      raise Mp3NodeException, e
    rescue Mp3Info => e
      $stderr.puts("Mp3Info problem: #{e}")
      raise Mp3NodeException, e
    rescue Mp3InfoInternalError => e
      $stderr.puts("Mp3InfoInternalError problem: #{e}")
      raise Mp3NodeException, e
    end
  end
  def save(attr)
    begin
      
      attr[:file_dir] = FileDir.find_or_create_by_name(attr.delete(:file_dir_name))
      @af = AudioFile.find_or_initialize_by_file_dir_id_and_filename(file_dir.id, file.filename.to_s)
      
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

  def album_dir=(val)
    rec[:album_dir] = val
  end
  def album_dir
    rec[:album_dir]
  end
  def dump(pfx)
    print pfx + ' > ' + file.filename.to_s 
    print ' - ' + self.rec[:artist_name].to_s + ' - ' + self.rec[:album_name].to_s 
    # $stderr.puts 'HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH' unless self.rec[:sample_rate] == 44100
    # print ' - ' + self.rec[:samplerate].to_s
    # print ' - ' + self.album_dir
    puts
  end

end

class DirNode
  attr_reader :dir, :dirnodes, :mp3nodes, :imgfiles, :depth, :parent
  def initialize(dir,parent=nil,depth=0)
    @dir = rio(dir)
    @artist_recs = {}
    @album_recs = {}
    @song_recs = {}
    @genre_recs = {}
    @file_dir_recs = {}
    @parent = parent
    @depth = depth
    @dirnodes = rio(dir).dirs[].map{ |d| DirNode.new(d,self,depth+1) }
    @mp3nodes = []
    @imgfiles = rio(dir).files('*.[Jj][Pp][Gg]')
    create_mp3nodes
    # p "#{dir} #{dirnodes.map{ |n| n.dir.to_s}}"
  end
  def unlink_parent
    dirnodes.each do |dn|
      dn.unlink_parent
    end
    @parent = nil
  end
  def adjust_album_dirs
    dirnodes.each do |dn|
      dn.adjust_album_dirs
    end
    if leaf? and albums.size == 1
      if siblings.any? { |sib| sib.leaf? && sib.albums == self.albums }
        p 'ADJUST ALBUM DIR'
        mp3nodes.each do |n|
          n.album_dir = parent.dir.to_s
        end
      end
    end
  end

  def siblings
    (@parent ? @parent.dirnodes.reject{|n| n == self } : [])
  end
  def albums
    mp3nodes.map{ |n| n.rec[:album_name] }.uniq
  end
  def all_albums
    aa = self.albums
    dirnodes.each do |dn|
      aa += dn.albums
    end
    aa.uniq
  end
  def leaf?
    @dirnodes.empty?
  end
  def create_mp3nodes
    dir.files('*.[Mm][Pp]3') do |f| 
      begin
        node = Mp3Node.new(f)
        @mp3nodes << node
      rescue Mp3NodeException => e
        p "#{f}: #{e}"
      end
    end
  end
  def artist_rec(name)
    @artist_recs[name] ||= Artist.find_or_create_by_name(name)
  end
  def song_rec(name)
    @song_recs[name] ||= Song.find_or_create_by_name(name)
  end
  def genre_rec(name)
    @genre_recs[name] ||= Genre.find_or_create_by_name(name)
  end
  def file_dir_rec(name)
    @file_dir_recs[name] ||= FileDir.find_or_create_by_name(name)
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

  def create_mp3attr(mp3node)
    rec = mp3node.rec
    attr = {
      :file_modified_time => rec[:file_modified_time],
      :file_size => rec[:file_size],
      :file_dir => self.file_dir_rec(self.dir.to_s),
          
      :artist => self.artist_rec(rec[:artist_name]),
      :song => self.song_rec(rec[:song_name]),
      :genre => self.genre_rec(rec[:genre_name]),
      :album => self.album_rec(rec[:album_name],mp3node.album_dir),

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
  def save
    puts ("   " * @depth) + @dir.to_s

    mp3nodes.each do |mp3node|
      mp3node.dump("   " * @depth)
      attr = self.create_mp3attr(mp3node)
      af = AudioFile.find_or_initialize_by_file_dir_id_and_filename(attr[:file_dir].id, mp3node.file.filename.to_s)
      
      af.attributes = attr
      af.save!
    end
    dirnodes.each do |dn|
      dn.save
    end
  end

  def dump
    puts ("   " * @depth) + @dir.to_s
    albms = self.all_albums
    puts ("   " * @depth) + albms.inspect unless albms.empty?
    mp3nodes.each do |node|
      node.dump("   " * @depth)
    end
    @dirnodes.each do |dn|
      dn.dump
    end
  end
end
