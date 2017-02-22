class GenresController < ApplicationController
  layout 'appfixed'

  def index
    @genre = Genre.page(params[:page]).per(15)
  end
end
