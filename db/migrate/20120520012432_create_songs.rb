class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.string :name, :null => false

      t.timestamps
    end
    add_index :songs, :name, :unique => true 

  end
end
