require 'test_helper'

class CatalogControllerTest < ActionController::TestCase

  test "should get catalog record" do
    get :show, id: "b3296321"
    assert_response :success
  end

end
