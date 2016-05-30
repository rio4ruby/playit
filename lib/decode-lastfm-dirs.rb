#!/usr/bin/env ruby

require 'rio'

rio('/mnt/files/lastfm/album').dirs do |artist_dir|
  ofilename = artist_dir.filename
  nfilename = URI.decode(ofilename.to_s)
  puts "#{artist_dir}::: #{ofilename} => #{nfilename}"
  artist_dir.rename.filename = nfilename

  # artist_dir.dirs do |album_dir|
    # puts "   #{album_dir}"
    # oadname = album_dir.filename
    # puts "   #{oadname}"
    # begin
    #   nadname = URI.decode(oadname.to_s)
    # rescue Exception
    #   nadname = oadname
    # end
    # puts "   #{oadname} => #{nadname}"
  # end
end
