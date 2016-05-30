class FileDirsController < InheritedResources::Base
  layout 'appfixed'

  def index
    @file_dirs = FileDir.page(params[:page]).per(15)
  end
end
