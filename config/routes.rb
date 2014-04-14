Absolute::Application.routes.draw do
  root 'catalog#index'

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  devise_for :users, controllers: { sessions: :sessions, registrations: :registrations}
  mount Hydra::RoleManagement::Engine => '/'
  mount Riiif::Engine => '/image-service'

  resources :admin_collections, controller: 'hydra/admin/collections'
  resource :admin_menu, only: :show, controller: 'admin_menu'

  resources :tei, only: :show
  
  curate_for

end