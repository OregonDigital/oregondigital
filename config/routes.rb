Oregondigital::Application.routes.draw do
  root :to => "catalog#index"

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'
  mount Qa::Engine => '/qa'
  resources :roles, :only => [] do
    resources :ip_ranges, :only => [:create, :destroy], :controller => "roles_ip_ranges"
  end

  # Downloads controller route
  resources :downloads, :only => "show"
  get '/sets(/:set(/:page))', :to => 'sets#index', :as => :sets
  get '/oai', :to => 'oai#index'

  # Ingest form routes
  resources :ingest
  resources :templates

  # Reviewer Controller Routes
  resources :reviewer, :only => [:index, :show, :update]

  # Generic Asset
  resources :generic_asset, :only => [] do
    member do
      put '/review', :to => 'generic_asset#review'
    end
  end

  # Static Pages
  get ':action' => 'static#:action', :constraints => { :action => /copyright|help/ }, :as => :static
end
