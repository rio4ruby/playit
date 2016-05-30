module ListNodesHelper

  def playlist(nodetree, node_id)
    list_node = nodetree.list_node(node_id)
    children = nodetree.children(node_id)
    playdata_class = list_node_playdata_class(list_node)
    playdata_data = list_node_playdata_data(list_node)
  end
    
end
  
