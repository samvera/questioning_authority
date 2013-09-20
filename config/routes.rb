QuestioningAuthority::Application.routes.draw do
  match "/search/:vocab" => "terms#search", :via=>:get
  match "/search/:vocab/:sub_authority" => "terms#search", :via=>:get
  match "/terms/:vocab" => "terms#index", :via=>:get
  match "/terms/:vocab/:sub_authority" => "terms#index", :via=>:get
  match "/show/:vocab/:id" => "terms#show", :via=>:get
  match "/show/:vocab/:sub_authority/:id" => "terms#show", :via=>:get
  resources :terms
end
