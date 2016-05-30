class CreateAudioFiles < ActiveRecord::Migration
  def change
    create_table :audio_files do |t|
      t.string :filename, :null => false
      t.references :file_dir, :null => false
      t.integer :file_size, :null => false
      t.datetime :file_modified_time, :null => false

      t.references :artist
      t.references :album
      t.references :song
      t.references :genre

      t.integer :tracknum
      t.integer :bitrate
      t.integer :samplerate
      t.float :length
      t.integer :layer
      t.integer :mpeg_version
      t.boolean :vbr
      t.integer :audio_start
      t.integer :audio_length
      t.string :mime_type, :limit => 50, :null => false

      t.timestamps
    end
    add_index :audio_files, [:file_dir_id,:filename], :unique => true
    add_index :audio_files, :file_dir_id
    add_index :audio_files, :artist_id
    add_index :audio_files, :album_id
    add_index :audio_files, :genre_id
  end
end
