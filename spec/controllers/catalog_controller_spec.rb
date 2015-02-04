require'spec_helper'

describe CatalogController do

  describe "route check" do
    it "should route /catalog/:id properly" do
      expect({get: '/catalog/b1234'}).to route_to(controller: 'catalog', action: 'show', id: 'b1234')
    end
  end

  #ToDo: below require a running Solr server.  We should mock these.
  #See for more examples: https://github.com/sul-dlss/SearchWorks/blob/master/spec/controllers/catalog_controller_spec.rb

  # test "CATALOG should get success response on good id" do
  #   get :show, { id: "b3296321" }  # Zen poems (use in Hay), 2002
  #   assert_response :success
  # end

  # test "OURL API should get success response on good id" do
  #   get :ourl_service, { id: "b3296321" }
  #   assert_response 200
  # end

  # test "OURL API should get success response response on bad id" do
  #   get :ourl_service, { id: "foo" }
  #   assert_response 404
  # end

  # test "OURL API response should contain isbn on modern work" do
  #   controller_test_instance = get :ourl_service, { id: "b3296321" }
  #   jhash = JSON.parse( controller_test_instance.body )
  #   assert_equal( ["id", "ourl"], jhash.keys.sort )
  #   assert_equal( true, jhash["ourl"].include?("ctx") )
  #   assert_equal( true, jhash["ourl"].include?("isbn") )  # should be `true` and should pass
  # end

end


