require 'test_helper'
require 'byebug'
require 'json'

class CatalogControllerTest < ActionController::TestCase

  test "CATALOG should get success response on good id" do
    get :show, { id: "b3296321" }  # Zen poems (use in Hay), 2002
    assert_response :success
  end

  test "OURL API should get success response on good id" do
    get :ourl_service, { id: "b3296321" }
    assert_response 200
  end

  test "OURL API should get success response response on bad id" do
    get :ourl_service, { id: "foo" }
    assert_response 404
  end

  test "OURL API response should contain isbn on modern work" do
    controller_test_instance = get :ourl_service, { id: "b3296321" }
    jdata = JSON.parse( controller_test_instance.body )
    print jdata["ourl"]
    assert_equal( true, jdata["ourl"].include?("ctx") )
    assert_equal( true, jdata["ourl"].include?("isbn") )  # should be `true` and should pass
  end

end
