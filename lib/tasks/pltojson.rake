# encoding: UTF-8
BEGIN {
  Encoding.default_internal = "UTF-8"
  Encoding.default_external = "UTF-8"
}

require 'pp'
require 'json'

namespace :development do
  task :pltojson, [:topdir, :needs] => [:environment] do |t,args|


    current_user = User.find(2)
    list_node = ListHead.my(current_user).playing.all.map(&:list_node).first


    node_id = list_node.id
    subtree = ListNode.includes(:listable).ordered.subtree_of(node_id).all
    nodetree = NodeTree.new(subtree).fill

    # ntjson = nodetree.to_json
    puts JSON.generate(nodetree, {:indent => "   ", :object_nl => "\n"})

  end
end
