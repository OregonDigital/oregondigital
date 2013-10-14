Oregondigital::Application.routes.draw do
  root :to => "catalog#index"

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'
  resources :roles, :only => [] do
    resources :ip_ranges, :only => [:create, :destroy], :controller => "roles_ip_ranges"
  end

  # Downloads controller route
  resources :downloads, :only => "show"
  get '/sets(/:set)', :to => 'sets#index', :as => :sets
end
