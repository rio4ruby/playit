class ImageFile < ActiveRecord::Base
  belongs_to :file_dir
  attr_accessible :filename, :file_dir, :file_modified_time, :format, :columns
  attr_accessible :rows,:depth,:number_colors, :filesize, :x_resolution, :y_resolution
  attr_accessible :units, :mime_type

  scope :midsize, lambda { 
    where(["image_files.columns < ? AND image_files.number_colors > ? ",325,1])
  }

  def filepath
    [self.file_dir.name,self.filename].join('/')
  end

  def fileurl
    self.filepath.sub('/srv/mp3/','')
  end

  def imageurl
    'http://media.kitatdot.net/image/' + URI.escape(self.fileurl)
    #['http://localhost/media',self.file_dir.name,self.filename].join('/')
  end

end
