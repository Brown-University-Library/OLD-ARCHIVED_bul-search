require "minitest/autorun"
class SearchCustomTest < Minitest::Test
  def test_exact_matches
    config = Blacklight.default_configuration
    searcher = SearchCustom.new(config)
    params = {}

    numbers = []
    numbers << "PQ9698.29.A51 V4x 1980"
    numbers << "HM146 .T3 1980"
    numbers << "fMusic SO1638n"
    numbers << "DD237 .K6713 1998 c.2"
    numbers << "2001 S3473 E75s"
    numbers << "ML410.B5 B29"
    numbers << "2-SIZE HB28952 PA"
    numbers.each do |q|
      response, docs, match = searcher.callnumber(q, params)
      assert docs.count == 1
      assert match == q
    end
  end

  def test_multiple_matches
    config = Blacklight.default_configuration
    searcher = SearchCustom.new(config)
    params = {}
    q = "AC145 .N563x 1995 v.20"
    response, docs, match = searcher.callnumber(q, params)
    assert docs.count > 1
    assert match == q
  end

  def test_variations
    config = Blacklight.default_configuration
    searcher = SearchCustom.new(config)
    params = {}

    # Find exact match...
    q = "Box 31 No.12"
    response, docs, match = searcher.callnumber(q, params)
    assert docs.count == 1
    assert match == q

    # ...and finds it even with different punctuation.
    q = "Box 31 No. 12"
    response, docs, match = searcher.callnumber(q, params)
    assert docs.count == 1
    assert match == "BOX|31|NO|12"

    # Finds even though original punctuation is different
    # ("PA4240.L5 H67 2018")
    q = "PA.4240 L5 H 67 2018"
    response, docs, match = searcher.callnumber(q, params)
    assert docs.count == 1
    assert match == "PA|4240|L|5|H|67|2018"
  end

  def test_partial_match
    # We don't have the "33rd" part of this call number in Solr
    # but we should still find it.
    config = Blacklight.default_configuration
    searcher = SearchCustom.new(config)
    params = {}
    q = "1-SIZE GN33 .G85 1994/1995 33rd"
    response, docs, match = searcher.callnumber(q, params)
    assert docs.count == 1
    assert match == '"GN33 .G85 1994/1995"'

    # The value indexed is "PQ2607.U8245 D68 1985" but will find a
    # partial match because it searches also without the last token (1985)
    q = "PQ2607.U8245 D68"
    response, docs, match = searcher.callnumber(q, params)
    assert docs.count == 1
    assert match == '"PQ2607.U8245"'
  end

  def test_wildcard
    config = Blacklight.default_configuration
    searcher = SearchCustom.new(config)

    q = "Cabinet Em 723 FeN"
    params = {}
    response, docs, match = searcher.callnumber(q, params)
    assert docs.count == 1
    assert match == q

    q = "Cabinet Em*"
    params = {"qt" => "document"}   # force MARC data (including item data) to be fetched
    response, docs, match = searcher.callnumber(q, params)
    assert docs.count > 1
    docs.each do |doc|
      assert doc.item_data.find {|item| item.call_number.upcase.include?("CABINET EM") }
    end
  end
end
