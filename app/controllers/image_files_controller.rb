class ImageFilesController < ApplicationController
  layout 'appfixed'

  def index
    @image_files = ImageFile.page(params[:page]).per(15)
  end
end
