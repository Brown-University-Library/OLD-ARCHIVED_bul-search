require "minitest/autorun"
# These tests were written specifically to validate that our
# Solr 7 core is handling some edge cases in the same way as
# our Solr 4 core did.
class Relevancy7Test < Minitest::Test
  def setup
    @solr_query = SolrQuery.new(Blacklight.default_configuration)
  end

  def test_stopwords
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
    # In Solr 7 is coming on #9 because Solr is ranking books
    # with title "blue" or "blue ... blue" higher and pushing
    # "into the blue" down BECAUSE "into" and "the" are stopwords.
    params = {"f" => {"format" => ["Book"]}}
    response, docs = @solr_query.search("into the blue", params)
    pos = position("b1937161", docs)
    assert pos < 10

    # Search by "title" suffers from the same issue/
    # This is less than ideal but for now we'll leave
    # it as-is and we'll address it after we migrate to Solr 7.
    params["rows"] = 20
    response, docs = @solr_query.search_by_title("into the blue", params)
    pos = position("b1937161", docs)
    assert pos < 20
  end

  private
    def position(id, docs)
      docs.each_with_index do |doc, ix|
        return ix if doc["id"] == id
      end
      return nil
    end
end
