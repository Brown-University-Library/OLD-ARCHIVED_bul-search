BulSearch::Application.routes.draw do
  root "easy#home"

  #catalog
  blacklight_for :catalog
  post 'catalog/sms' => 'catalog#sms'
  Blacklight::Marc.add_routes(self)
  get 'catalog/:id/ourl' => 'catalog#ourl_service', as: :catalog_service_ourl
  devise_for :users, :controllers => {omniauth_callbacks: 'omniauth_callbacks'},
      :skip => [:sessions]

  #easySearch
  get "easy/search"
  get 'easy/' => 'easy#home', as: :easyS
  get 'easy/search'

  #libweb
  get 'libweb/' => 'libweb#search', as: :lib_web

end
