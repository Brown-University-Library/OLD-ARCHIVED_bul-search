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

  private
    def position(id, docs)
      docs.each_with_index do |doc, ix|
        return ix if doc["id"] == id
      end
      return nil
    end
end
