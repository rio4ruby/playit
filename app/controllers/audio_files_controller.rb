class AudioFilesController < InheritedResources::Base
  layout Proc.new { |controller| controller.request.xhr? ? false : 'appfixed' }

  def index
    @q = params[:q]
    per_page = 15
    if @q
      @search = Sunspot.search(AudioFile) do |s|
        s.keywords @q
        
        s.paginate :page => params[:page], :per_page => per_page
      end
      @audio_files = @search.results
    else
      @audio_files = AudioFile.page(params[:page]).per(per_page)
    end
  end

  def add
    @id = params[:id]
    list_node = current_user.list_heads.playing.first.list_node
    new_node = AudioFile.find(@id).create_list_node(list_node)
    @node_id = new_node.id
    subtree = ListNode.includes(:listable).ordered.subtree_of(@node_id).all
    @nodetree = NodeTree.new(subtree)

    respond_to do |format|
      format.js
    end
  end

  def add_to_playing
    @id = params[:id]
    list_node = current_user.list_heads.playing.first.list_node
    new_node = AudioFile.find(@id).create_list_node(list_node)
    @node_id = new_node.id
    subtree = ListNode.includes(:listable).ordered.subtree_of(@node_id).all
    @nodetree = NodeTree.new(subtree)

    respond_to do |format|
      format.js
    end
  end



end
