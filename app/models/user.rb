class User < ActiveRecord::Base
	rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :confirmed_at
  
  after_create :create_playing_playlist

  has_many :list_heads

  private
    def create_playing_playlist
      list_head = ListHead.create!(:name => 'Playing', :is_playing => true, :user => self)
      list_node = ListNode.create!(:listable => list_head)
      Rails.logger.info("CREATE_PLAYING_PLAYLIST: #{self.email} list_node = #{list_node}");
    end

end
