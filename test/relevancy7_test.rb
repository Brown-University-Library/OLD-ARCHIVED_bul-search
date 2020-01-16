require "minitest/autorun"
# These tests were written specifically to validate that our
# Solr 7 core is handling some edge cases in the same way as
# our Solr 4 core did.
class Relevancy7Test < Minitest::Test
  def setup
    @solr_query = SolrQuery.new(Blacklight.default_configuration)
  end

  def test_stopwords
    # In Solr 7 we expect this search to find items.
    # In Solr 4 we got no results because we were using stop
    # words on titles.
    response, docs = @solr_query.search("There There", {})
    assert docs.count > 0

    # "at" is a stop word for `text_general` fields in Solr 4
    # and therefore should be a match for this record since
    # the Table of Contents includes "Young at heart".
    params = {"fq" => "pub_date_sort:1995"}
    response, docs = @solr_query.search("Young heart", params)
    assert position("b2724484", docs) < 10
  end

  def test_character_folding
    # Makes sure character folding (e == é) is enabled.
    response1, docs = @solr_query.search("san jose", {})
    response2, docs = @solr_query.search("san josé", {})
    assert response1["response"]["numFound"] == response2["response"]["numFound"]
  end

  def test_exact_title
    # In Solr 4 the seach by "all fields" returns item
    #   bib: b1937161
    #   title: Into the blue
    # on the first position which makes sense.
    #
    # In Solr 7 by default this record comes in #9 because Solr is ranking
    # books with title "blue" or "blue something blue" higher and pushing
    # "into the blue" down BECAUSE "into" and "the" are stopwords.
    # With the addition of a field title_strict_key_search we are
    # getting the title back on top. Yay!
    params = {"f" => {"format" => ["Book"]}}
    response, docs = @solr_query.search("into the blue", params)
    pos = position("b1937161", docs)
    assert pos < 5

    # Search by "title" suffers from the same issue by default.
    # This test make sure we don't revert back to the default Solr 7
    # behavior.
    response, docs = @solr_query.search_by_title("into the blue", params)
    pos = position("b1937161", docs)
    assert pos < 5
  end

  private
    def position(id, docs)
      docs.each_with_index do |doc, ix|
        return ix if doc["id"] == id
      end
      return nil
    end
end
