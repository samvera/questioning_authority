Qa::Engine.routes.draw do
  get "/terms/:vocab(/:subauthority)",  controller: :terms, action: :index
  get "/search/:vocab(/:subauthority)", controller: :terms, action: :search
  get "/show/:vocab/:id",                controller: :terms, action: :show
  get "/show/:vocab/:subauthority/:id", controller: :terms, action: :show
end
