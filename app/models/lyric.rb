class Lyric < ActiveRecord::Base
  belongs_to :artist
  belongs_to :song
  attr_accessible :l_artist, :l_song, :l_url, :text, :artist_id, :song_id

  searchable :auto_index => true, :auto_remove => true do
    integer :id

    text :text, :stored => true, :boost => 10

    # text :text, :as => :text_textp, :stored => true, :boost => 6

    # text :artist_name, :boost => 1.5, :as => :artist_name_textp  do
    #   (artist ? artist.name : "")
    # end
    # text :song_name, :boost => 3.0, :as => :song_name_textp  do
    #   (song ? song.name : "")
    # end


    # text :l_artist, :as => :l_artist_textp
    # string :l_artist
    
    # text :l_song, :as => :l_song_textp
    # string :l_song
    
    
    # integer :song_id, :references => Song
    # integer :artist_id, :references => Artist

  end
  MSTR = "[...]\n\n" +
      "Unfortunately, we are not licensed to display the full lyrics for this\n" +
      "song at the moment. Hopefully we will be able to in the future. Until\n" +
      "then, how about a random page?\n\n" +
      "[I want to edit metadata]"


  def lyric_text_to_html(txt)
    txt.sub(MSTR,'&hellip;')
  end
  def html_text
    lyric_text_to_html(text).gsub("\n","<br/>")
  end


end
