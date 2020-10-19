require "minitest/autorun"
class OnlineAvailDataTest < Minitest::Test
  def test_links
    # Josiah link
    link = OnlineAvailData.new("http://josiah.brown.edu/record=b7506363", "text")
    assert link.url == "http://search.library.brown.edu/catalog/b7506363"

    # Non-Josiah link
    link = OnlineAvailData.new("http://whatever.org/123?q=qwerty", "text")
    assert link.url == "http://whatever.org/123?q=qwerty"
  end
end
