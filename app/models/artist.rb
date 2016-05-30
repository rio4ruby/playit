class Artist < ActiveRecord::Base
  attr_accessible :name, :wikiname

  validates :name, :presence => true, :uniqueness => true

  has_many :audio_files, :dependent => :nullify
  has_many :albums, :through => :audio_files
  has_many :songs, :through => :audio_files
  has_many :genres, :through => :audio_files
  has_many :file_dirs, :through => :audio_files
  has_many :solo_albums, :foreign_key => :album_artist_id, :class_name => 'Album'


  searchable :auto_index => true, :auto_remove => true do
    integer :id

    string :name
    text :name_text, :boost => 0.9 do
      name
    end
    text :name_textp, :stored => true, :boost => 0.5, :as => :name_textp do
      name
    end

    text :album_names, :boost => 0.2  do
      (albums.map(&:name).join(' '))
    end
    # text :song_names, :boost => 0.1  do
    #   (songs.map(&:name).join(' '))
    # end
    
    # text :name, :stored => true, :boost => 9, :as => :name_textp 

    # text :album_names, :boost => 4, :as => :album_names_textp  do
    #   (albums.map{ |a| a.name }.join(' '))
    # end

    # text :song_names, :boost => 3, :as => :song_names_textp  do
    #   (songs.map{ |a| a.name }.join(' '))
    # end

    # integer :album_ids, :multiple => true, :references => Album
    # integer :song_ids, :multiple => true, :references => Song
    # integer :audio_file_ids, :multiple => true, :references => AudioFile
    # integer :genre_ids, :multiple => true, :references => Genre
    # integer :lyric_ids, :multiple => true, :references => Lyric

  end


end
