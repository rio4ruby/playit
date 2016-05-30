class Album < ActiveRecord::Base
  attr_accessible :album_dir_id, :name
  attr_accessible :album_artist_id, :album_image_file_id

  validates :name, :presence => true, :uniqueness => { :scope => :album_dir_id }
  
  belongs_to :album_dir, :class_name => 'FileDir'
  belongs_to :album_artist, :class_name => 'Artist'
  belongs_to :album_image_file, :class_name => 'ImageFile'

  has_many :audio_files, :dependent => :nullify, :order => 'tracknum'
  has_many :artists, :through => :audio_files
  has_many :songs, :through => :audio_files
  has_many :genres, :through => :audio_files
  has_many :file_dirs, :through => :audio_files
  has_many :image_files, :through => :file_dirs

  has_many :list_nodes, :as => :listable



  searchable :auto_index => true, :auto_remove => true do
    integer :id

    string :name
    text :name_text, :boost => 0.8 do
      name
    end
    text :name_textp, :stored => true, :boost => 0.5, :as => :name_textp do
      name
    end


    text :artist_names, :boost => 0.5  do
      (artists.map{ |a| a.name }.join(' '))
    end
    text :song_names, :boost => 0.5  do
      (songs.map{ |a| a.name }.join(' '))
    end

    # text :name, :stored => true, :boost => 8, :as => :name_textp 

    # text :artist_names, :boost => 3, :as => :artist_names_textp  do
    #   (artists.map{ |a| a.name }.join(' '))
    # end

    # text :song_names, :boost => 3, :as => :song_names_textp  do
    #   (songs.map{ |a| a.name }.join(' '))
    # end


    # integer :artist_ids, :multiple => true, :references => Artist
    # integer :song_ids, :multiple => true, :references => Song
    # integer :audio_file_ids, :multiple => true, :references => AudioFile
    # integer :genre_ids, :multiple => true, :references => Genre
  end

  def album_artist_name
    album_artist ? album_artist.name : nil
  end
  
  def create_list_node_all(parent,filter_recs=[])
    new_node = parent.children.create(:listable => self)
    create_list_node_children(new_node,filter_recs)
  end
  def create_list_node(parent)
    new_node = parent.children.create(:listable => self)
    new_node
  end
  def create_list_node_children(parent,filter_recs=[])
    self.audio_files.limit_to(*filter_recs).order("tracknum").each do |af|
      af.create_list_node(parent)
      p "CREATE_LIST_NODE for #{af} in parent=#{parent.id}"
    end
    parent
  end


  def node_class(node)
    classes = ""
    audio_files = node.children.all.map{|ch| ch.listable}
    artists = audio_files.map(&:artist)
    if artists.uniq.size == 1
      classes += "single-artist"
    else
      classes += "multi-artist"
    end
    classes
  end





end
