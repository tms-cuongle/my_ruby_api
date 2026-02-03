namespace :api do
  namespace :v1 do
    post "auth/login", to: "authentication#login"
    post "uploads", to: "uploads#create"
    resources :users
  end
end
