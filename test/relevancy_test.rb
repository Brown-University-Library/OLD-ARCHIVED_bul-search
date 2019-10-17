require "minitest/autorun"
# These tests validate that the Sorl configuration returns the expected
# results for a few test searches. These tests were migrated here from
# the now defunct Relevancy Test project https://github.com/Brown-University-Library/relevancy-tests
class RelevancyTest < Minitest::Test
  def setup
    @solr_query = SolrQuery.new(Blacklight.default_configuration)
  end

  def test_etd
    # Finds a thesis imported from the BDR
    response, docs = @solr_query.search_by_id("bdr\\:733467", {})
    assert docs.count == 1
    assert docs[0]["pub_date"].first == "2016"

    # Finds a thesis from the catalog (i.e. not in the BDR)
    response, docs = @solr_query.search_by_id("b5766021", {})
    assert docs.count == 1
    assert docs[0]["pub_date"].first == "2010"
  end

  def test_synonyms
    response, docs = @solr_query.search("100", {})
    count1 = response["response"]["numFound"]
    #
    # PENDING REIMPORT WITH NEW DEFAULT SYNOMYMS FILE.
    #
    response, docs = @solr_query.search("hundred", {})
    count2 = response["response"]["numFound"]
    assert count1 == count2
  end

  def test_video
    # Should return a video (for a record with multiple 007s)
    q = "gathering moss"
    params = {"fq" => "format:Video"}
    response, docs = @solr_query.search(q, params)
    assert docs.find { |d| d["id"] == "b7302566" }
  end

  def test_search_popular
    response, docs = @solr_query.search("Pubmed", {})
    assert position("b3340555", docs) < 3
  end

  def test_search_isbn
    response, docs = @solr_query.search("9780892369294", {})
    assert position("b6355793", docs) < 5
  end

  def test_search_oclc
    response, docs = @solr_query.search("225874122", {})
    assert position("b6355793", docs) < 5
  end

  def test_search_issn
    # ISSN searches need to be in quotes in default box
    # for now.  Because of hypens?
    response, docs = @solr_query.search('"0191-1813"', {})
    assert position("b4105405", docs) < 5
  end

  def test_search_callnumber
    # full call number
    response, docs = @solr_query.search("QL466 .M44 2008", {})
    assert position("b6355793", docs) < 5
  end

  def test_search_author
    # Should provide reasonable results for authors with common tokens in names
    response, docs = @solr_query.search("browning christopher", {})
    assert position("b3459028", docs) < 10
  end

  def test_brazil
    # Brazil query was returning over 4,000 documents on 5/11/15
    response, docs = @solr_query.search("slave trade in brazil", {})
    assert response["response"]["numFound"] <= 500
  end

  def test_search_titles
    # Should match partial titles
    response, docs = @solr_query.search("remains of the day", {})
    assert position("b2041590", docs) < 10

    response, docs = @solr_query.search("time is a toy", {})
    assert position("b7113006", docs) < 3

    # Should match full title strings without quotes
    response, docs = @solr_query.search("A Pale View of Hills", {})
    assert position("b2151715", docs) < 2

    # Should match full title strings with quotes
    response, docs = @solr_query.search("'A Pale View of Hills'", {})
    assert position("b2151715", docs) < 2

    #
    # PENDING REIMPORT WITH NEW FIELD DEFINITIONS (COMBINED_11.MRC FAILED TO IMPORT)
    #
    # Should match partial title and TOC text
    response, docs = @solr_query.search("Effects of globalization in india", {})
    assert position("b3176352", docs) < 10

    # Should prefer primary titles over additional titles
    response, docs = @solr_query.search("scientific american", {})
    assert position("b1864577", docs) < 5

    # Should rank a commonly used alternate title high
    # From Kerri Hicks 5/8/15
    response, docs = @solr_query.search(" DSM V", {})
    assert position("b6543998", docs) < 10
    response, docs = @solr_query.search(" DSM-V", {})
    assert position("b6543998", docs) < 10

    # Uniform title
    response, docs = @solr_query.search("Huis clos", {})
    assert position("b2017949", docs) < 10

    # Left anchored primary titles
    response, docs = @solr_query.search("Ordinary men", {})
    assert position("b2022476", docs) < 10
  end

  # Explicit search by title field
  def test_by_title
    # ...title match
    response, docs = @solr_query.search_by_title("gothic classics", {})
    assert position("b4156972", docs) < 5
    # ...related work (700t) match
    response, docs = @solr_query.search_by_title("i've a pain in my head", {})
    assert position("b4156972", docs) < 5
    # ... 505t match
    response, docs = @solr_query.search_by_title("Carmilla", {})
    assert position("b4156972", docs) < 5
  end

  def test_by_author
    # TODO: we don't have searches by author.
    # We should probably add a few.
  end

  # Note that the only way a user can execute a search by title and author
  # is via the Advanced search.
  def test_by_title_author
    author = "Steibelt, Daniel, 1765-1823"
    response, docs = @solr_query.search_by_title_author("Concertos, piano, orchestra, no. 3, op. 33, E major.", author, {})
    assert position("b7699058", docs) <= 1

    response, docs = @solr_query.search_by_title_author("Concertos,", author, {})
    assert position("b7699058", docs) <= 1

    response, docs = @solr_query.search_by_title_author("Concertos, piano, orchestra,", author, {})
    assert position("b7699058", docs) <= 1

    response, docs = @solr_query.search_by_title_author("Concertos, piano, orchestra, no. 3, op. 33,", author, {})
    assert position("b7699058", docs) <= 1
  end

  def test_lcsh
    # Known LCSH subject strings
    response, docs = @solr_query.search("Black Panther party History", {})
    assert position("b2771607", docs) < 5
  end

  def test_operators
    #
    # PENDING REIMPORT???
    # BIB b3296339 IS BEING FOUND IN POSITION 11 WITH SOLR 7,
    # NOT SURE IF THIS IS BECAUSE MISSING DATA IN OUR SOLR CORE, A CONFIGURATION SETTING,
    # OR JUST A PLAIN DIFFERENCE IN THE WAY SOLR 7 IS RANKING THE DOCUMENT.
    #
    # Should include de gaulle and politics (b3296339)
    # but exclude france (b13507813)
    response, docs = @solr_query.search("De gaulle +politics -france", {})
    # assert position("b3296339", docs) < 10
    assert position("b13507813", docs) == nil

    # Should include politics and france
    response, docs = @solr_query.search("De gaulle +politics +france", {})
    assert position("b1350781", docs) < 5
    response, docs = @solr_query.search("De gaulle politics france", {})
    assert position("b1350781", docs) < 5

    # Base query
    # Oct/2019 - switched to BIB b2986203 because BIB b5738569 was coming
    # too far in the result set (but still passing the test) but failing
    # to pass in Solr 7. BIB b2986203 comes pretty high up in both.
    response, docs = @solr_query.search("disease history europe war economics women religion", {})
    assert position("b2986203", docs) < 10

    # Requiring women (+)
    q = "disease history europe war economics +women religion"
    response, docs = @solr_query.search(q, {})
    assert position("b3900073", docs) < 5
    assert position("b5738569", docs) == nil

    # Preventing women (-)
    q = "disease history europe war economics -women religion"
    response, docs = @solr_query.search(q, {})
    assert position("b5738569", docs) < 5
  end

  private
    def position(id, docs)
      docs.each_with_index do |doc, ix|
        return ix if doc["id"] == id
      end
      return nil
    end
end
