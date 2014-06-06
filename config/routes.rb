Absolute::Application.routes.draw do
  root 'catalog#index'
  mount Worthwhile::Engine, at: '/'
  blacklight_for :catalog
  devise_for :users, controllers: { sessions: :sessions, registrations: :registrations}

  mount Hydra::RoleManagement::Engine => '/'

  # TODO secure resque admin interface - allow admin users only
  mount Resque::Server => '/queues'
  mount Riiif::Engine => '/image-service'
  #mount Worthwhile::Engine, at: '/'
  mount Hydra::Collections::Engine => '/'
  worthwhile_curation_concerns
  worthwhile_collections
  worthwhile_embargo_management

  resource :admin_menu, only: :show, controller: 'admin_menu'
end
