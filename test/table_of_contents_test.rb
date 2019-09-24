require "minitest/autorun"
class TableOfContentsTest < Minitest::Test
  def test_chapters
    toc970 = [JSON.generate([{"title" => "970 title"}])]
    toc505 = [JSON.generate([{"title" => "505 title"}])]

    # defaults to 970
    toc = TableOfContents.new(toc970, nil)
    assert toc.chapters[0]["title"] == "970 title"

    toc = TableOfContents.new(toc970, toc505)
    assert toc.chapters[0]["title"] == "970 title"

    # honors 505
    toc = TableOfContents.new(nil, toc505)
    assert toc.chapters[0]["title"] == "505 title"

    # makes sure defaults are sensible
    toc = TableOfContents.new([JSON.generate([{}])], nil)
    assert toc.chapters[0]["label"] == ""
    assert toc.chapters[0]["indent"] == ""
    assert toc.chapters[0]["authors"] == []
    assert toc.chapters[0]["title"] == ""
    assert toc.chapters[0]["page"] == ""
  end
end