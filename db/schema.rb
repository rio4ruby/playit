# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120606071222) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "albums", :force => true do |t|
    t.string   "name",                :null => false
    t.integer  "album_dir_id",        :null => false
    t.integer  "album_artist_id"
    t.integer  "album_image_file_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "albums", ["album_dir_id", "name"], :name => "index_albums_on_album_dir_id_and_name", :unique => true

  create_table "artists", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "wikiname"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "artists", ["name"], :name => "index_artists_on_name", :unique => true

  create_table "audio_files", :force => true do |t|
    t.string   "filename",                         :null => false
    t.integer  "file_dir_id",                      :null => false
    t.integer  "file_size",                        :null => false
    t.datetime "file_modified_time",               :null => false
    t.integer  "artist_id"
    t.integer  "album_id"
    t.integer  "song_id"
    t.integer  "genre_id"
    t.integer  "tracknum"
    t.integer  "bitrate"
    t.integer  "samplerate"
    t.float    "length"
    t.integer  "layer"
    t.integer  "mpeg_version"
    t.boolean  "vbr"
    t.integer  "audio_start"
    t.integer  "audio_length"
    t.string   "mime_type",          :limit => 50, :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "audio_files", ["album_id"], :name => "index_audio_files_on_album_id"
  add_index "audio_files", ["artist_id"], :name => "index_audio_files_on_artist_id"
  add_index "audio_files", ["file_dir_id", "filename"], :name => "index_audio_files_on_file_dir_id_and_filename", :unique => true
  add_index "audio_files", ["file_dir_id"], :name => "index_audio_files_on_file_dir_id"
  add_index "audio_files", ["genre_id"], :name => "index_audio_files_on_genre_id"

  create_table "audio_files_tags", :force => true do |t|
    t.integer  "audio_file_id", :null => false
    t.integer  "tag_id",        :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "audio_files_tags", ["audio_file_id", "tag_id"], :name => "index_audio_files_tags_on_audio_file_id_and_tag_id", :unique => true

  create_table "file_dirs", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "ancestry"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "file_dirs", ["name"], :name => "index_file_dirs_on_name", :unique => true

  create_table "genres", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "genres", ["name"], :name => "index_genres_on_name", :unique => true

  create_table "image_files", :force => true do |t|
    t.string   "filename",                         :null => false
    t.integer  "file_dir_id",                      :null => false
    t.datetime "file_modified_time",               :null => false
    t.string   "format",                           :null => false
    t.integer  "columns",                          :null => false
    t.integer  "rows",                             :null => false
    t.integer  "depth",                            :null => false
    t.integer  "number_colors",                    :null => false
    t.integer  "filesize",                         :null => false
    t.float    "x_resolution",                     :null => false
    t.float    "y_resolution",                     :null => false
    t.string   "units"
    t.string   "mime_type",          :limit => 50, :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "image_files", ["file_dir_id", "filename"], :name => "index_image_files_on_file_dir_id_and_filename", :unique => true

  create_table "list_heads", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",                          :null => false
    t.boolean  "is_playing", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "list_heads", ["user_id", "name"], :name => "index_list_heads_on_user_id_and_name", :unique => true

  create_table "list_nodes", :force => true do |t|
    t.string   "ancestry"
    t.integer  "ancestry_depth"
    t.integer  "position"
    t.integer  "listable_id",    :null => false
    t.string   "listable_type",  :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "list_nodes", ["listable_id", "listable_type"], :name => "index_list_nodes_on_listable_id_and_listable_type"

  create_table "lyrics", :force => true do |t|
    t.string   "l_artist"
    t.string   "l_song"
    t.text     "text",                      :null => false
    t.string   "l_url",      :limit => 500
    t.integer  "artist_id",                 :null => false
    t.integer  "song_id",                   :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "lyrics", ["artist_id", "song_id"], :name => "index_lyrics_on_artist_id_and_song_id", :unique => true

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "songs", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "songs", ["name"], :name => "index_songs_on_name", :unique => true

  create_table "tags", :force => true do |t|
    t.string   "name",       :limit => 4, :null => false
    t.string   "value",                   :null => false
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "tags", ["name", "value"], :name => "index_tags_on_name_and_value", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

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
