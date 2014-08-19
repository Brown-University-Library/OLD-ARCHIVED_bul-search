BulSearch::Application.routes.draw do
  root "easy#home"

  #catalog
  blacklight_for :catalog
  post 'catalog/sms' => 'catalog#sms'
  Blacklight::Marc.add_routes(self)
  get 'catalog/:id/ourl' => 'catalog#ourl_service', as: :catalog_service_ourl
  devise_for :users, :controllers => {omniauth_callbacks: 'omniauth_callbacks'}

  #easySearch
  get "easy/search"
  get 'easy/' => 'easy#home', as: :easyS
  get 'easy/search'

  #bdr
  get 'bdr/advanced' => 'bdr_advanced#index', as: :bdr_advanced_search
  get 'bdr' => 'bdr#index', as: :bdr_index
  get 'bdr/email' => 'bdr#email', as: :email_bdr
  post 'bdr/email' => 'bdr#email', as: :bdr_email
  get 'bdr/sms' => 'bdr#sms', as: :sms_bdr
  post 'bdr/sms' => 'bdr#sms', as: :bdr_sms
  post 'bdr/:id/track' => 'bdr#track', as: :bdr_track
  get 'bdr/:id' => 'bdr#show', as: :bdr_solr_document

  #libweb
  get 'libweb/' => 'libweb#search', as: :lib_web

end
