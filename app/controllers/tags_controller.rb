class TagsController < ApplicationController
  layout 'appfixed'

  def index
    @tags = Tag.page(params[:page]).per(15)
  end
end
