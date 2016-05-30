class Tag < ActiveRecord::Base
  attr_accessible :name, :value

  validates :name, :presence => true
  validates :value, :presence => true

  # has_many :audio_files_tags, :dependent => :delete_all
  has_many :audio_files_tags
  has_many :audio_files, :through => :audio_files_tags

end
