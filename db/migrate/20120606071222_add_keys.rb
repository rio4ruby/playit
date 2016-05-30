class AddKeys < ActiveRecord::Migration
  def change
    add_foreign_key "albums", "artists", :name => "albums_album_artist_id_fk", :column => "album_artist_id"
    add_foreign_key "albums", "file_dirs", :name => "albums_album_dir_id_fk", :column => "album_dir_id"
    add_foreign_key "albums", "image_files", :name => "albums_album_image_file_id_fk", :column => "album_image_file_id"
    add_foreign_key "audio_files", "albums", :name => "audio_files_album_id_fk"
    add_foreign_key "audio_files", "artists", :name => "audio_files_artist_id_fk"
    add_foreign_key "audio_files", "file_dirs", :name => "audio_files_file_dir_id_fk"
    add_foreign_key "audio_files", "genres", :name => "audio_files_genre_id_fk"
    add_foreign_key "audio_files", "songs", :name => "audio_files_song_id_fk"
    add_foreign_key "audio_files_tags", "audio_files", :name => "audio_files_tags_audio_file_id_fk", :dependent => :delete
    add_foreign_key "audio_files_tags", "tags", :name => "audio_files_tags_tag_id_fk", :dependent => :delete
    add_foreign_key "image_files", "file_dirs", :name => "image_files_file_dir_id_fk"
    add_foreign_key "list_heads", "users", :name => "list_heads_user_id_fk"
    add_foreign_key "lyrics", "artists", :name => "lyrics_artist_id_fk"
    add_foreign_key "lyrics", "songs", :name => "lyrics_song_id_fk"
  end
end
