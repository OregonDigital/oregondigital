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

  # Ingest form routing
  get 'ingest(/:id)/form', to: 'ingest#form', as: :show_ingest_form
end
