Rails.application.routes.draw do
  mount Spree::Core::Engine,  at: '/'

  authenticate :spree_user, lambda { |u| u.admin? } do
    mount Sidekiq::Web, at: '/admin/tasks'
  end
end

# To ensure correct route precedence, list similar routes first
# ie. 'products/autocomplete' would call 'products/show' with id
Spree::Core::Engine.routes.draw do
  # root to: 'home#index'
  get '/search',                 to: 'home#search', as: :search

  namespace :blog do
    # Or configure NGINX proxy pass
      # server {
      # listen 8082;
      # server_name 127.0.0.1;
      # location / {
      #     proxy_pass http://forum.example.com;
      # }
    # }
    root to: redirect('http://127.0.0.1:2368/')

    authenticate :spree_user, lambda { |u| u.admin? } do
      get '/admin', to: redirect('http://127.0.0.1:2368/ghost/')
    end
  end

  namespace :msa do
    root to: 'msa#index'
    get '/tutors',    to: 'msa#index'
    get '/workshops', to: 'msa#index'
  end

  get '/help',                   to: 'help#index'
  get '/about',                  to: 'about#index'

  get 'products/latest',         to: 'products#latest', via: :get, as: :latest
  get 'products/autocomplete',   to: 'products#autocomplete', via: :get, as: :autocomplete, format: 'json'
  # resources :products, :only => [:index, :show, :autocomplete] do
  #   collection do
  #     match :autocomplete, to: 'products#autocomplete', via: :get, format: 'json'
  #   end
  # end

  # namespace :api, defaults: { format: 'json' } do
  #   get 'products/autocomplete', to: 'products#autocomplete', as: :products_autocomplete
  #   resources :products do
  #     get 'autocomplete'
  #   end
  # end
end

Spree::Core::Engine.routes.append do
  namespace :admin do
    resources :xero_session do
      collection do
        get :contacts
        get :invoices
      end
    end

    resources :reports, only: [:index] do
      collection do
        get :new_users_by_date
        get :products_by_category
        get :monthly_revenue
        get :monthly_tax
        get :interest_groups
        # post :sales_total
      end
    end
  end
end


# Storytime::Engine.routes.draw do
#   #root to: "application#setup"
#
#
# end
#
# Cardboard::Engine.routes.draw do
#   #root to: 'application#setup'
#
# end

# mount Storytime::Engine,    at: '/blog/storytime'
# mount Cardboard::Engine,    at: '/blog/cardboard'

# Override engien routes sos that they're all using the Spree:userr Devise methods.

# devise_for :spree_user,
#            :class_name => 'Spree::User',
#            :controllers => { :sessions => 'spree/user_sessions',
#                              :registrations => 'spree/user_registrations',
#                              :passwords => 'spree/user_passwords',
#                              :confirmations => 'spree/user_confirmations' },
#            :skip => [:unlocks, :omniauth_callbacks],
#            :path_names => { :sign_out => 'logout' },
#            :path_prefix => :user
#
# devise_scope :spree_user do
#   get '/login' => 'user_sessions#new', :as => :login
#   post '/login' => 'user_sessions#create', :as => :create_new_session
#   get '/logout' => 'user_sessions#destroy', :as => :logout
#   get '/signup' => 'user_registrations#new', :as => :signup
#   post '/signup' => 'user_registrations#create', :as => :registration
#   get '/password/recover' => 'user_passwords#new', :as => :recover_password
#   post '/password/recover' => 'user_passwords#create', :as => :reset_password
#   get '/password/change' => 'user_passwords#edit', :as => :edit_password
#   put '/password/change' => 'user_passwords#update', :as => :update_password
#   get '/confirm' => 'user_confirmations#show', :as => :confirmation if Spree::Auth::Config[:confirmable]

#
# namespace :admin do
#   #   devise_for :spree_user,
#   #              :class_name => 'Spree::User',
#   #              :controllers => { :sessions => 'spree/admin/user_sessions',
#   #                                :passwords => 'spree/admin/user_passwords' },
#   #              :skip => [:unlocks, :omniauth_callbacks, :registrations],
#   #              :path_names => { :sign_out => 'logout' },
#   #              :path_prefix => :user
#   #
#   #   devise_scope :spree_user do
#   #     get '/authorization_failure', :to => 'user_sessions#authorization_failure', :as => :unauthorized
#   #     get '/login' => 'user_sessions#new', :as => :login
#   #     post '/login' => 'user_sessions#create', :as => :create_new_session
#   #     get '/logout' => 'user_sessions#destroy', :as => :logout
#   #   end
# end