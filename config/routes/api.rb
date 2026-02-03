namespace :api do
  namespace :v1 do
    post "auth/login", to: "authentication#login"
    post "auth/register", to: "authentication#register"
    delete "auth/logout", to: "authentication#logout"
    post "auth/forgot_password", to: "authentication#forgot_password"
    post "auth/reset_password", to: "authentication#reset_password"

    post "uploads", to: "uploads#create"
    resources :users
  end
end
