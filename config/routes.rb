BulSearch::Application.routes.draw do
  root "easy#home"

  #catalog
  blacklight_for :catalog
  post 'catalog/sms' => 'catalog#sms'
  Blacklight::Marc.add_routes(self)
  get 'catalog/:id/ourl' => 'catalog#ourl_service', as: :catalog_service_ourl
  devise_for :users, :controllers => {omniauth_callbacks: 'omniauth_callbacks'},
      :skip => [:sessions]

  # bookplate_list
  get 'catalog/bookplate/:bookplate_code' => 'catalog#bookplate'

  #easySearch
  get "easy/search"
  get 'easy/' => 'easy#home', as: :easyS
  get 'easy/search'

  #libweb
  get 'libweb/' => 'libweb#search', as: :lib_web

  # Browse (aka Virtual Shelf)
  get 'browse/' => 'browse#random', as: :browse_random
  get 'browse/about' => 'browse#about', as: :browse_about
  get 'browse/:id' => 'browse#from_item', as: :browse_item

  # Course Reserves
  get 'reserves/search' => 'reserves#search', as: :reserves_search
  get 'reserves/:classid/:classnumber' => 'reserves#show', as: :reserves_show
  get 'reserves/' => 'reserves#search'

  # Stub controller to test the Availability Service
  get 'availability/test_auth' => 'availability#test_auth'
  get 'availability/fake/:id' => 'availability#fake_one'
  post 'availability/fake/' => 'availability#fake_many'
  get 'availability/forward/:id' => 'availability#forward_one'
  post 'availability/forward/' => 'availability#forward_many'

  # API controller
  get 'api/items/by_location' => 'api#items_by_location'
  get 'api/items/nearby' => 'api#items_nearby'
  get 'api/items/shelf_item/:id' => 'api#shelf_item'
  get 'api/items/shelf_items' => 'api#shelf_items'
end
