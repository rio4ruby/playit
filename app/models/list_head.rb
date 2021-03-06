class ListHead < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :is_playing, :user

  has_one :list_node, :as => :listable

  scope :my, lambda { |user|
    where("list_heads.user_id = ?", user.id)
  }
  scope :playing, lambda {
    where(:is_playing => true)
  }

  scope :ordered, lambda {
    order("list_heads.list_class ASC, list_heads.name ASC")
  }

  def node_class(node)
    ""
  end

end
