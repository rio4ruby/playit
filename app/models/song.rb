class Song < ActiveRecord::Base
  attr_accessible :name

  validates :name, :presence => true, :uniqueness => true

  has_many :audio_files, :dependent => :nullify
  has_many :artists, :through => :audio_files
  has_many :albums, :through => :audio_files
  has_many :genres, :through => :audio_files
  has_many :file_dirs, :through => :audio_files

  has_many :lyrics, :dependent => :nullify

  searchable :auto_index => true, :auto_remove => true do
    integer :id

    text :name, :stored => true, :boost => 10
    text :name, :stored => true, :boost => 6.5, :as => :name_textp 
    text :artist_names, :boost => 2  do
      (artists.map(&:name).uniq.join(' '))
    end
    text :album_names, :boost => 2  do
      (albums.map(&:name).uniq.join(' '))
    end
    # text :name, :stored => true, :boost => 7, :as => :name_textp 

    # text :artist_names, :boost => 2, :as => :artist_names_textp  do
    #   (artists.map{ |a| a.name }.uniq.join(' '))
    # end
    # text :album_names, :boost => 2, :as => :album_names_textp  do
    #   (albums.map{ |a| a.name }.uniq.join(' '))
    # end
    # text :lyrics_text, :stored => true, :boost => 1.5, :as => :lyrics_text_textp  do
    #   (lyrics.compact.map{ |a| a.text }.uniq.join(' '))
    # end

    # integer :artist_ids, :multiple => true, :references => Artist
    # integer :album_ids, :multiple => true, :references => Album
    # integer :audio_file_ids, :multiple => true, :references => AudioFile
    # integer :lyric_ids, :multiple => true, :references => Lyric
    # integer :genre_ids, :multiple => true, :references => Genre
  end



end
