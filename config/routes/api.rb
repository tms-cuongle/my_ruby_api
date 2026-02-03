namespace :api do
  namespace :v1 do
    controller :authentication do
      post "auth/login", action: :login
      post "auth/register", action: :register
      delete "auth/logout", action: :logout
      post "auth/forgot_password", action: :forgot_password
      post "auth/reset_password", action: :reset_password
    end

    controller :uploads do
      post "uploads", action: :create
    end

    controller :users do
      post "users/avatar", action: :upload_avatar
    end
    resources :users
  end
end
