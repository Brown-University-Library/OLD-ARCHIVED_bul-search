require "minitest/autorun"
class EasyHelperTest < Minitest::Test
  include EasyHelper
  def test_escape
    val = worldcat_search("<&$!#@>!badquery")
    assert val == "http://worldcat.org.revproxy.brown.edu/search?&q=%3C%26%24%21%23%40%3E%21badquery"

    val = bdr_search("<&$!#@>!badquery")
    assert val == "https://repository.library.brown.edu/studio/search/?q=%3C%26%24%21%23%40%3E%21badquery"
  end
end
