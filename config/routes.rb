Qa::Engine.routes.draw do
  get "/terms/:vocab(/:sub_authority)",  controller: :terms, action: :index
  get "/search/:vocab(/:sub_authority)", controller: :terms, action: :search
  get "/show/:vocab/:id",                controller: :terms, action: :show
  get "/show/:vocab/:sub_authority/:id", controller: :terms, action: :show
end
