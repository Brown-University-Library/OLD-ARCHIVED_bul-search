require "minitest/autorun"
class SearchCustomTest < Minitest::Test
  def test_exact_matches
    searcher = SearchCustom.new(Blacklight.default_configuration)
    numbers = []
    numbers << "PQ9698.29.A51 V4x 1980"
    numbers << "HM146 .T3 1980"
    numbers << "fMusic SO1638n"
    numbers << "DD237 .K6713 1998 c.2"
    numbers << "2001 S3473 E75s"
    numbers << "ML410.B5 B29"
    numbers << "2-SIZE HB28952 PA"
    numbers << "PQ2607.U8245 D68 1985"
    numbers.each do |q|
      response, docs, match = searcher.callnumber(q, {})
      assert docs.count == 1
      assert match == q
    end
  end

  def test_multiple_matches
    searcher = SearchCustom.new(Blacklight.default_configuration)
    q = "AC145 .N563x 1995 v.20"
    response, docs, match = searcher.callnumber(q, {})
    assert docs.count > 1
    assert match == q
  end

  def test_variations
    searcher = SearchCustom.new(Blacklight.default_configuration)

    # Find exact match...
    q = "Box 31 No.12"
    response, docs, match = searcher.callnumber(q, {})
    assert docs.count == 1
    assert match == q

    # ...and finds it even with different punctuation.
    q = "Box 31 No. 12"
    response, docs, match = searcher.callnumber(q, {})
    assert docs.count == 1
    assert match == "BOX|31|NO|12"

    # Finds even though original punctuation is different
    # ("PA4240.L5 H67 2018")
    q = "PA.4240 L5 H 67 2018"
    response, docs, match = searcher.callnumber(q, {})
    assert docs.count == 1
    assert match == "PA|4240|L|5|H|67|2018"
  end

  def test_partial_match
    # Should find it without the "33rd" (we don't index that token)
    # and without the "1-SIZE" (we don't index that token)
    searcher = SearchCustom.new(Blacklight.default_configuration)
    q = "1-SIZE GN33 .G85 1994/1995 33rd"
    response, docs, match = searcher.callnumber(q, {})
    assert docs.count == 1
    assert match == "GN|33|G|85|1994|1995"

    # Should find the shortened version.
    q = "HM146 .T3 1980 bogus"
    response, docs, match = searcher.callnumber(q, {})
    assert docs.count == 1
    assert match == "HM|146|T|3|1980"

    # Should not find it (nor the shortened version "N 6797")
    q = "N6797.G65"
    response, docs, match = searcher.callnumber(q, {})
    assert docs.count == 0

    # Should not find it (nor the shortened version "PA 4240")
    q = "PA 4240.L5"
    response, docs, match = searcher.callnumber(q, {})
    assert docs.count == 0

    # Should not find it (and the shortened version is too short to retry)
    q = "PA 4240"
    response, docs, match = searcher.callnumber(q, {})
    assert docs.count == 0
  end

  def test_wildcard
    searcher = SearchCustom.new(Blacklight.default_configuration)

    q = "Cabinet Em 723 FeN"
    params = {}
    response, docs, match = searcher.callnumber(q, params)
    assert docs.count == 1
    assert match == q

    q = "Cabinet Em*"
    params = {"qt" => "document"}   # force MARC data to be fetched so we can analyze item_data
    response, docs, match = searcher.callnumber(q, params)
    assert docs.count > 1
    docs.each do |doc|
      assert doc.item_data.find {|item| item.call_number.upcase.include?("CABINET EM") }
    end

    # Handles the weird punctuaction correctly
    q = "PA 4240.L5*"
    response, docs, match = searcher.callnumber(q, {})
    assert docs.count > 0
    assert match == "PA|4240|L|5*"
  end
end
