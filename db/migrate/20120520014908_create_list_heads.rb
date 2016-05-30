class CreateListHeads < ActiveRecord::Migration
  def change
    create_table :list_heads do |t|
      t.references :user
      t.string :name, :null => false
      t.boolean :is_playing, :default => false

      t.timestamps
    end
    add_index :list_heads, [:user_id,:name], :unique => true
  end
end
