Absolute::Application.routes.draw do
  root 'catalog#index'
  mount Worthwhile::Engine, at: '/'
  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  devise_for :users, controllers: { sessions: :sessions, registrations: :registrations}
  mount Hydra::RoleManagement::Engine => '/'
  # TODO secure resque admin interface - allow admin users only
  mount Resque::Server => '/queues'
  mount Riiif::Engine => '/image-service'
  worthwhile_collections
  worthwhile_curation_concerns
  # mount Worthwhile::Engine, at: '/'
end
