class OneController < ApplicationController
  before_filter :authenticate_user!

  def playlist
    get_data
  end
  def get_data
    @list_node = ListHead.my(current_user).playing.all.map(&:list_node).first


    @node_id = @list_node.id
    subtree = ListNode.includes(:listable).ordered.subtree_of(@node_id).all
    @nodetree = NodeTree.new(subtree)
    
    @playdata = cookies[:playing]
    unless @playdata && @nodetree.playdata_in_tree(@playdata)
      @playdata = @nodetree.create_playdata(@nodetree.first_audio_file_node)
    end
    if @playdata
      cookies[:playing] = { :value => @playdata, :expires => Time.now + 3600*24*7}
    else
      cookies[:playing] = nil
    end
  end

  def search
  end

  def player
    get_data
  end

  def lyric
  end

  def wiki
  end
end
