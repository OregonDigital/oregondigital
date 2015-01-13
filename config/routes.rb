require 'resque-retry'
require 'resque-retry/server'
Oregondigital::Application.routes.draw do

  root :to => redirect { |params, request| "/catalog?#{request.params.to_query}"}
  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  devise_for :users
  authenticate :user, lambda {|u| u.admin?} do
    mount Resque::Server.new, :at => "/resque"
  end
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

  # Bulk Ingest Routes
  resources :bulk_tasks, :only => [:index, :show, :update] do
    member do
      put '/ingest', :to => 'bulk_tasks#ingest'
      put '/reset', :to => 'bulk_tasks#reset_task'
      put '/refresh', :to => 'bulk_tasks#refresh'
      put '/review_all', :to => 'bulk_tasks#review_all'
      delete '/delete', :to => 'bulk_tasks#delete'
      delete '/reset', :to => 'bulk_tasks#reset'
      delete '/stop_ingest', :to => 'bulk_tasks#stop_ingest'
    end
  end
  resources :bulk_task_children, :only => [:show]

  # Reviewer Controller Routes
  resources :reviewer, :only => [:index, :show, :update] do
    collection do
      get 'facet/:id', :to => "reviewer#facet"
    end
  end

  # Contact Form Routes
  post '/contact' => 'contact_form#create', :as => :contact_form_index
  get '/contact' => 'contact_form#new'

  # Generic Asset
  resources :generic_asset, :only => [:destroy] do
    member do
      put '/review', :to => 'generic_asset#review'
    end
  end

  # Destroyed Object Management
  resources :destroyed, :only => [:index] do
    member do
      put '/undelete', :to => 'destroyed#undelete'
    end
  end

  # Document Metadata
  resources :document, :only => [:show] do
    member do
      get 'fulltext/(:q)', :to => 'document#fulltext'
    end
  end

  # Resource routes
  resources :resource, :only => [:show]

  # Static Pages
  get ':action' => 'static#:action', :constraints => { :action => /copyright|help/ }, :as => :static
end
