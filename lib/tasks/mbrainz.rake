# encoding: UTF-8
BEGIN {
  Encoding.default_internal = "UTF-8"
  Encoding.default_external = "UTF-8"
}

require 'cgi'
require 'open-uri'
require 'rio'
require 'xmlsimple'
require 'dbi'
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
def get_canonical_artist_name(conn,name)
  can_name = name
  nm = URI.escape(name)
#  uri = URI('http://localhost:5000/ws/2/artist/?query=' + nm)
#  req = Net::HTTP::Get.new(uri.request_uri)

  res = Net::HTTP.start('localhost', 5000) do |http|
    response = http.get('/ws/2/artist/?query=' + nm, {'User-Agent'=>'ruby/net::http'})
    case response
    when Net::HTTPSuccess     then response
    else
      response.error!
    end
  end

  resp = res.body

  st = XmlSimple.xml_in(resp, { 
                          :KeyAttr => 'name', 
                          :ForceArray => false, 
                          :GroupTags => { 'alias-list' => 'alias', 'tag-list' => 'tag' },
                        })['artist-list']
  
  if st
    st['artist'].each do |artist_name,v|
      #p v
      can_name = artist_name if (artist_name == name || [v['alias-list']].flatten.any?{|al| al == name})
    end
  else
    p res
  end
  can_name
end
def get_artist_sql0
  sql = %{
select distinct artist.id,an.name,at.name,artist.gid
from artist_name an,artist_alias al, artist_name alan, artist, artist_name ansn, artist_type at
where ( (an.name = ?) or (alan.name = ?) or (ansn.name = ?) )  
and alan.id = al.name
and artist.name = an.id
and al.artist = artist.id
and artist.sort_name = ansn.id
and artist.type = at.id
}
end

def get_artist_sql 
  sql = %{
select distinct artist.id,an.name,at.name,artist.gid
from artist_name an,artist_alias al, artist_name alan, artist, artist_name ansn, artist_type at
where an.name = ?
and alan.id = al.name
and artist.name = an.id
and al.artist = artist.id
and artist.sort_name = ansn.id
and artist.type = at.id
}
end
def get_artist_sql1
  sql = %{
select distinct artist.id,an.name,at.name,artist.gid
from artist_name an,artist_alias al, artist_name alan, artist, artist_name ansn, artist_type at
where alan.name = ?
and alan.id = al.name
and artist.name = an.id
and al.artist = artist.id
and artist.sort_name = ansn.id
and artist.type = at.id
}
end
def get_artist_sql2
  sql = %{
select distinct artist.id,an.name,at.name,artist.gid
from artist_name an,artist_alias al, artist_name alan, artist, artist_name ansn, artist_type at
where ansn.name = ?
and alan.id = al.name
and artist.name = an.id
and al.artist = artist.id
and artist.sort_name = ansn.id
and artist.type = at.id
}
end
def get_release_sql1
  sql = %{
select rn.name
from release_name rn
where ( (rn.name = ?) )
}
end


def get_tracks_sql1 
  sql = %{
select 
distinct
rg.id,
release.id,
medium.id,
rn.name,
an.name, 
mf.name,
medium.position,
tl.track_count,
track.position,
tn.name,
rec.gid

from release_name rn, medium, release, artist_credit ac,
artist_name an,medium_format mf,tracklist tl,release_group rg,track,track_name tn, recording rec
where ( (rn.name = ?) )
and medium.release = release.id
and release.name = rn.id
and release.artist_credit = ac.id
and ac.name = an.id
and medium.format = mf.id
and medium.tracklist = tl.id
and release.release_group = rg.id
and rg.artist_credit = ac.id
and track.tracklist = tl.id
and track.name = tn.id
and track.artist_credit = ac.id
and rec.id = track.recording
and rec.artist_credit = ac.id
and rec.name = tn.id

order by rg.id,release.id,medium.position,mf.name,track.position
}
end
def get_tracks_sql2
  sql = %{
select 
distinct
rg.id,
release.id,
medium.id,
rn.name,
an.name, 
mf.name,
medium.position,
tl.track_count,
track.position,
tn.name,
rec.gid

from release_name rn, medium, release, artist_credit ac,
artist_name an,medium_format mf,tracklist tl,release_group rg,track,track_name tn, recording rec
where ( (rn.name = ?) and ( an.name = ? ) )
and medium.release = release.id
and release.name = rn.id
and release.artist_credit = ac.id
and ac.name = an.id
and medium.format = mf.id
and medium.tracklist = tl.id
and release.release_group = rg.id
and rg.artist_credit = ac.id
and track.tracklist = tl.id
and track.name = tn.id
and track.artist_credit = ac.id
and rec.id = track.recording
and rec.artist_credit = ac.id
and rec.name = tn.id

order by rg.id,release.id,medium.position,mf.name,track.position
}
end

def get_rg_sql1 
  sql = %{
select distinct
an.name,
rgrn.name,
rg.gid,
art.gid

from 
release rl, 
release_name rlrn, 
release_group rg,
release_name rgrn, 
artist_credit rlac,
artist_credit rgac,
artist art,
artist_name an

where ( (rgrn.name = ?) and (an.name = ?) )
and rl.release_group = rg.id
and rl.artist_credit = rlac.id
and rl.name = rlrn.id
and rg.name = rgrn.id
and rg.artist_credit = rgac.id
and rlac.name = an.id
and rgac.name = an.id
and art.name = an.id

order by art.gid,rg.gid,an.name,rgrn.name
}
end

def find_an(sth,name)
  sth.execute(name)
  anfound = false
  r = nil
  while row = sth.fetch do
    anfound = true
    r = row
    break
  end
  return r
end
def find_rn(sth,name)
  sth.execute(name)
  rnfound = false
  while row = sth.fetch do
    rnfound = true
    p row
  end
end
def find_tracks_rn(sth,name)
  sth.execute(name)
  rnfound = false
  while row = sth.fetch do
    rnfound = true
    p row
  end
end
def find_rg_rn(sth,name,aname)
  sth.execute(name,aname)
  rnfound = false
  while row = sth.fetch do
    rnfound = true
    p row
  end
end
def find_tracks_rn_an(sth,release_name,artist_name)
  sth.execute(release_name,artist_name)
  rnfound = false
  while row = sth.fetch do
    rnfound = true
    p row
  end
end

namespace :development do
  task :mbrainz3, [:topdir, :needs] => [:environment] do |t,args|
    DATAROOT = '/srv/data/lyrics'
    XMLDIR = rio(DATAROOT,'xml')
    PAGEDIR = rio(DATAROOT,'pages')
    TXTDIR = rio(DATAROOT,'txt')
    
    # Connect to a database, old style
    dbh = DBI.connect('DBI:Pg:musicbrainz_db', 'musicbrainz', 'musicbrainz')
    rgsql1 = get_rg_sql1()
    rgsth1 = dbh.prepare(rgsql1)
    
    Artist.includes(:albums).order("artists.name").all.each do |artist|
      artist.albums.uniq.each do |album|
        #puts "#{artist.name}\t#{alb.name}"
        find_rg_rn(rgsth1,album.name,artist.name)
      end
    end
  end
  
  task :mbrainz2, [:topdir, :needs] => [:environment] do |t,args|
    DATAROOT = '/srv/data/lyrics'
    XMLDIR = rio(DATAROOT,'xml')
    PAGEDIR = rio(DATAROOT,'pages')
    TXTDIR = rio(DATAROOT,'txt')

    # Connect to a database, old style
    dbh = DBI.connect('DBI:Pg:musicbrainz_db', 'musicbrainz', 'musicbrainz')
    rnsql1 = get_release_sql1()
    rnsth1 = dbh.prepare(rnsql1)

    trackssql1 = get_tracks_sql1()
    trackssth1 = dbh.prepare(trackssql1)

    trackssql2 = get_tracks_sql2()
    trackssth2 = dbh.prepare(trackssql2)

    AudioFile.includes(:song,:artist,:album).all.each do |af|
      puts "#{af.artist_name}\t#{af.album_name}\t#{af.song_name}"
      release_name = af.album_name
      find_tracks_rn_an(trackssth2,release_name,af.artist_name)
    end
  end









  task :mbrainz, [:topdir, :needs] => [:environment] do |t,args|
    DATAROOT = '/srv/data/lyrics'
    XMLDIR = rio(DATAROOT,'xml')
    PAGEDIR = rio(DATAROOT,'pages')
    TXTDIR = rio(DATAROOT,'txt')

    # Connect to a database, old style
    dbh = DBI.connect('DBI:Pg:musicbrainz_db', 'musicbrainz', 'musicbrainz')
    sql = get_artist_sql()
    sth = dbh.prepare(sql)

    sql1 = get_artist_sql1()
    sth1 = dbh.prepare(sql1)

    sql2 = get_artist_sql2()
    sth2 = dbh.prepare(sql2)

    acount = 0
    ancount = 0
    alcount = 0
    sncount = 0
    tcount = 0
    Artist.all.each do |artist|
      acount += 1
      name = artist.name
      #puts name
      #next
      anfound = false
      row = find_an(sth,name)
      if row
        ancount += 1
        anfound = true
      else
        row1 = find_an(sth1,name)
        if row1
          alcount += 1
        else
          row2 = find_an(sth2,name)
          if row2
            sncount += 1
          else
            puts "\t#{name}"
         end
        end
      end
      tcount = ancount + alcount + sncount 
      print "\r#{ancount}/#{alcount}/#{sncount}/#{tcount}/#{acount}"
    end
    puts "\r#{ancount}/#{alcount}/#{sncount}/#{tcount}/#{acount}"
  end
end
