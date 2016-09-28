Rails.application.routes.draw do
  use_doorkeeper do
    controllers :applications => 'oauth/applications'
  end
  devise_for :users, controllers: { sessions: "users/sessions" }, only: :sessions

  root 'home#index'
  get "/users" => "users#index", as: :users

  get "/users/forgotten_password" => "users#forgotten_password", as: :forgotten_password
  post "/users/send_reset_instructions" => "users#send_reset_instructions", as: :send_reset_instructions
  get "/users/reset_password" => "users#reset_password", as: :edit_password
  post "/users/modify_password" => "users#modify_password", as: :modify_password
  
  resources :users, only: [:edit, :update] do
    put "/password" => "users#update_password", as: :update_password
    get "/password" => "users#edit_password"
    get "/profile"  => "users#profile", as: :profile
  end

  get '/soon' => "home#coming_soon", as: :soon

  namespace :api do
    namespace :v1 do
      get '/me' => 'api#me'
    end
  end

  get '/calendar' => 'calendar#index', as: :calendar

  get '/files/*path' => 'files#index', as: :files
  get '/files' => 'files#index', as: :base_files

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
