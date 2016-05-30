class PlayersController < ApplicationController
  def mini
    @list_node = ListHead.my(current_user).playing.all.map(&:list_node).first


    @node_id = @list_node.id
    subtree = ListNode.includes(:listable).ordered.subtree_of(@node_id).all
    @nodetree = NodeTree.new(subtree)
    
    @audio_file_nodes = @nodetree.audio_file_list_nodes

  end
  def simple
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

  def flatten_nodes(nodes)
    

  end


end
