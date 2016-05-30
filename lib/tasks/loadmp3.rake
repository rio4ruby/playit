# encoding: utf-8
require 'mp3info'
require 'rio'
require 'populator'

$stdout.sync = 1
rio('log').mkdir
LOGGER_PATH = "log/loadmp3.error.log"
logger = Logger.new(LOGGER_PATH)
#logger.datetime_format = "%Y-%m-%d %H:%M:%S"
logger.formatter = proc { |severity, datetime, progname, msg|
  "#{datetime} [#{severity}]: #{msg}\n"
}

default_mp3dir = '/srv/mp3'
default_glob = '*'


namespace :development do
  task :loadmp3file, [:topdir, :needs] => [:environment] do |t,args|
    Slog.open("loadmp3file")
    fn = '/srv/mp3/Cake/(1996) Fashion Nugget/08 - Stickshifts and Safetybelts.mp3'
    afinfo = Populator::AfInfo.new(fn);
    if af = afinfo.populate
      aftags = Populator::AfTags.new(fn,af,afinfo.mp3info)
      aftags.populate
    end
  end
  task :loadmp3dir, [:topdir, :needs] => [:environment] do |t,args|
    Slog.open("loadmp3dir")
    dn = '/srv/mp3/Cake'
    pop = Populator.new('/srv/mp3')
    pop.populate_dirs(dn)
  end

  task :updatewikinames, [:topdir, :needs] => [:environment] do |t,args|
    Slog.open("updatewikinames")
    Artist.all.each do |artist|
      own = artist.wikiname
      nwn = Populator.to_wikiname(artist.name)
      if own != nwn
        puts "#{artist.name} => #{own} => #{nwn}"
        artist.wikiname = nwn
        artist.save!
      end
    end
  end

  task :copy_mp3s_to_srv, :mp3dir do |t,args|
    args.with_defaults(:mp3dir => default_mp3dir)
    sh "cp -urv /mnt/hdd/mp3/* #{args[:mp3dir]}"
  end
  desc "Update Album Ids"
  task :update_album_ids, [:glob,:mp3dir] => [:environment] do |t,args|
    args.with_defaults(:glob => default_glob, :mp3dir => default_mp3dir)
    Album.all.each do |album|
      image_file = album.image_files.midsize.uniq.first
      if image_file
        album.album_image_file = image_file
      end
      artists = album.artists.uniq
      if artists.size == 1
        album.album_artist = artists.first
      end
      album.save!
      if album.album_artist || album.album_image_file
        puts "#{album.name}"
        puts " -- ARTIST: #{album.album_artist.name}" if album.album_artist
        puts " -- IMAGE_FILE: #{album.album_image_file.filepath}" if album.album_image_file
      end
    end
  end
  desc "Populate db from mp3 files"
  task :loadmp3, [:glob,:mp3dir] => [:environment] do |t,args|
    args.with_defaults(:glob => default_glob, :mp3dir => default_mp3dir)
    pop = Populator.new(args[:mp3dir]);
    pop.populate(args[:glob])
  end
  task :updatemp3, [:glob,:mp3dir] => :environment do |t,args|
    args.with_defaults(:glob => default_glob, :mp3dir => default_mp3dir)
    require 'updater'
    updater = Updater.new(args[:mp3dir])
    updater.run(args[:glob])
  end
  task :checkdb, [:glob,:mp3dir] => :environment do |t,args|
    args.with_defaults(:glob => default_glob, :mp3dir => default_mp3dir)
    require 'updater'
    updater = Updater.new(args[:mp3dir])
    updater.check_db
  end
  task :syncfs, :glob, :mp3dir do |t,args|
    args.with_defaults(:glob => default_glob, :mp3dir => default_mp3dir)
    Rake.application.invoke_task("development:copy_mp3s_to_srv[#{args[:mp3dir]}]")
    puts "development:checkdb[#{args[:glob]},#{args[:mp3dir]}]"
    Rake.application.invoke_task("development:checkdb[#{args[:glob]},#{args[:mp3dir]}]")
    puts "development:updatemp3[#{args[:glob]},#{args[:mp3dir]}]"
    Rake.application.invoke_task("development:updatemp3[#{args[:glob]},#{args[:mp3dir]}]")
  end

  task :loadmp3nodes, [:topdir, :needs] => [:environment] do |t,args|
    require 'dirnode'
    rio('/srv/mp3').skip.dirs('[DTV]*') do |dir|
      dn = DirNode.new(dir)
      dn.adjust_album_dirs
      dn.save
      dn.unlink_parent
    end
  end
  task :loadjpg, [:topdir, :needs] => [:environment] do |t,args|
    pop = Populator.new('/srv/mp3');
    rio('/srv/mp3').all.dirs do |dir|
      puts dir
      pop.process_image_files(dir)
    end
  end
  task :loadmp3filedir, [:topdir, :needs] => [:environment] do |t,args|
    fd = FileDir.find_or_create_by_name('/srv/mp3/Cake')
    puts "#{fd}\t#{fd.name}"
    puts "   parent: #{fd.parent.inspect}"
    if fd.parent
      puts "   parent val: #{fd.parent.name}"
    end
    pie = FileDir.find_or_create_by_name('/srv/mp3/Pie')
    fd = FileDir.find_or_create_by_name('/srv/mp3/Pie/Piece')
    fd = FileDir.find_or_create_by_name('/srv/mp3/Pie/Chart')
    fd = FileDir.find_or_create_by_name('/srv/mp3/Pie/Piece/Pumpkin')
    fd = FileDir.find_or_create_by_name('/srv/mp3/Pie/Piece/Apple')
    FileDir.destroy(pie.id)

  end

end
