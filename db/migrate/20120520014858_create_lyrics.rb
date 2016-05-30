class CreateLyrics < ActiveRecord::Migration
  def change
    create_table :lyrics do |t|
      t.string :l_artist
      t.string :l_song
      t.text :text, :null => false
      t.string :l_url, :limit => 500
      t.references :artist, :null => false
      t.references :song, :null => false

      t.timestamps
    end
    add_index :lyrics, [:artist_id, :song_id], :unique => true
  end
end
