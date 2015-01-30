Absolute::Application.routes.draw do
  root 'catalog#index'
  mount Worthwhile::Engine, at: '/'
  blacklight_for :catalog
  devise_for :users, controllers: { sessions: :sessions, registrations: :registrations}

  mount Hydra::RoleManagement::Engine => '/'

  # Checks to see if the user has access to the page. Currently, this is defined in admin_permission
  constraints ResqueAdmin do
    mount Resque::Server, at: '/queues'
  end
  #This line is only called if the user does not meet the above constraints. It loads a page which CanCan tries to authorize. Since it can't, it performs the default behavior of displaying a flash message.
  resource :queues, controller: 'queues'
  get '/queues/*other', to: redirect('/queues')

  mount Riiif::Engine => '/image-service'
  mount Hydra::Collections::Engine => '/'
  worthwhile_curation_concerns
  worthwhile_collections
  worthwhile_embargo_management

  resource :admin_menu, only: :show, controller: 'admin_menu'
  match 'catalog/export_ris/:id', to: 'catalog#export_ris', via: [:get, :post]

  post '/bulk_update/replace_subject', to: 'bulk_update#replace_subject'
  post '/bulk_update/split_subject', to: 'bulk_update#split_subject'
  post '/bulk_update/replace_language', to: 'bulk_update#replace_language'
  post '/bulk_update/replace_person', to: 'bulk_update#replace_person'
  get '/bulk_update', to: 'bulk_update#index'

  post '/submit/submit', to: 'submit#submit'
  get '/submit/thanks', to: 'submit#thanks'
  get '/submit', to: 'submit#index'

  get 'content_manager', to: 'content_manager#index'
end
