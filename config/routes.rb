Oregondigital::Application.routes.draw do
  root :to => redirect { |params, request| "/catalog?#{request.params.to_query}"}
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
  get '/sets', :to => 'sets#index', :as => :sets_index
  # Display a set landing page - restrict so that facets don't hit this route.
  get '/sets/(:set(/page/:page))', :to => 'sets#index', :as => :sets, :constraints => {:set => /[A-Za-z0-9\-]*/}, :as => :sets
  # Facets limitations
  get '/sets/facet/:id', :to => 'sets#facet'
  get '/sets/:set/facet/:id', :to => 'sets#facet', :as => :sets_facet
  get '/sets/:set/:id', :to => 'sets#show'
  put '/sets/:set/:id', :to => 'sets#update'
  patch '/sets/:set/:id', :to => 'sets#update'

  get '/oai', :to => 'oai#index'

  # Ingest form routes
  resources :ingest
  resources :templates

  # Reviewer Controller Routes
  resources :reviewer, :only => [:index, :show, :update]

  # Contact Form Routes
  post '/contact' => 'contact_form#create', :as => :contact_form_index
  get '/contact' => 'contact_form#new'

  # Generic Asset
  resources :generic_asset, :only => [] do
    member do
      put '/review', :to => 'generic_asset#review'
    end
  end

  # Static Pages
  get ':action' => 'static#:action', :constraints => { :action => /copyright|help/ }, :as => :static
end
