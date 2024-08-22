Rails.application.routes.draw do
  
  resources :users, only: [:create] do
    collection do
      get :check_email 
    end
  end
end
