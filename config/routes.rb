Qa::Engine.routes.draw do
  get "/search/linked_data/:vocab(/:subauthority)", controller: :linked_data_terms, action: :search
  get "/show/linked_data/:vocab/:id", controller: :linked_data_terms, action: :show
  get "/show/linked_data/:vocab/:subauthority/:id", controller: :linked_data_terms, action: :show
  get "/terms/:vocab(/:subauthority)",  controller: :terms, action: :index
  get "/search/:vocab(/:subauthority)", controller: :terms, action: :search
  get "/show/:vocab/:id", controller: :terms, action: :show
  get "/show/:vocab/:subauthority/:id", controller: :terms, action: :show
end
