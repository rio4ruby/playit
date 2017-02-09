Playit::Application.routes.draw do

  get "one/playlist"

  get "one/search"

  get "one/player"

  get "one/lyric"

  get "one/wiki"

  get "players/mini"
  get "players/simple"

  get "list_nodes/clear"
  get "list_nodes/flatten"
  get "list_nodes/move_to"
  get "list_nodes/add_to_playing"
  post "list_nodes/playlist_playable_items"
  resources :list_nodes

  resources :list_heads

  resources :lyrics

  resources :image_files

  resources :audio_files_tags

  get "audio_files/add_to_playing"
  resources :audio_files do
    member do
      get 'add'
    end
  end

  resources :tags

  resources :genres

  resources :songs

  get "albums/lookup"
  get "albums/add_to_playing"
  get "albums/search"

  resources :albums do
    member do
      get 'image'
      get 'add'
    end
  end

  get "artists/search"
  resources :artists do
    resources :albums do
      get 'add'
    end
  end

  resources :file_dirs

  devise_for :admin_users

  authenticated :user do
    root :to => 'home#index'
    #root :to => 'one#playlist'
  end
  root :to => "home#index"

  get "home/main"
  get "home/search"
  get "home/dosearch"
  post "home/aside"
  get "home/playing_lyrics"
  get "home/playing_wiki"
  devise_for :users
  resources :users, :only => [:show, :index]
end
