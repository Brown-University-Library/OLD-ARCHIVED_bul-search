BulSearch::Application.routes.draw do
  get "easy/search"
  root :to => "catalog#index"
  blacklight_for :catalog
  post 'catalog/sms' => 'catalog#sms'
  Blacklight::Marc.add_routes(self)
  devise_for :users

  get 'catalog/:id/ourl' => 'catalog#ourl_service', as: :catalog_service_ourl

  get 'easy/' => 'easy#home', as: :easyS
  get 'easy/search'
  get 'bdr/advanced' => 'bdr_advanced#index', as: :bdr_advanced_search
  get 'bdr' => 'bdr#index', as: :bdr_index
  get 'bdr/email' => 'bdr#email', as: :email_bdr
  post 'bdr/email' => 'bdr#email', as: :bdr_email
  get 'bdr/sms' => 'bdr#sms', as: :sms_bdr
  post 'bdr/sms' => 'bdr#sms', as: :bdr_sms
  post 'bdr/:id/track' => 'bdr#track', as: :bdr_track
  get 'bdr/:id' => 'bdr#show', as: :bdr_solr_document

  get 'libweb/' => 'libweb#search', as: :lib_web
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
