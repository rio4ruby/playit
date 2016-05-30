class AudioFilesTag < ActiveRecord::Base
  belongs_to :audio_file
  belongs_to :tag
  # attr_accessible :title, :body
end
