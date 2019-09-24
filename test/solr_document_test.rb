require "minitest/autorun"
class SolrDocumentTest < Minitest::Test
  def test_has_toc
    # empty doc
    empty_doc = SolrDocument.new(source_doc={})
    assert !empty_doc.has_toc?

    empty_doc = SolrDocument.new(source_doc={"id" => "b123456"})
    assert !empty_doc.has_toc?

    # handle 505 toc
    solr_doc = SolrDocument.new(source_doc={"toc_display" => ["test toc"]})
    assert solr_doc.has_toc?

    # handle 505 toc
    solr_doc = SolrDocument.new(source_doc={"toc_970_display" => ["test toc"]})
    assert solr_doc.has_toc?

    # handles both kinds of toc
    solr_doc = SolrDocument.new(source_doc={"toc_display" => ["test 505 toc"], "toc_970_display" => ["test 970 toc"]})
    assert solr_doc.has_toc?
  end

  def test_get_toc
    # Table of contents with 970 info
    solr_doc = SolrDocument.new(source_doc={"toc_970_display" => [JSON.generate([{"title" => "970"}])]})
    assert solr_doc.get_toc.chapters[0]["title"] == "970"

    # Table of contents with 505 info
    solr_doc = SolrDocument.new(source_doc={"toc_display" => [JSON.generate([{"title" => "505"}])]})
    assert solr_doc.get_toc.chapters[0]["title"] == "505"
  end

  def test_uniform_titles
    empty_doc = SolrDocument.new(source_doc={})
    assert !empty_doc.has_uniform_titles?
    assert empty_doc.get_uniform_titles == []

    # detects all types of uniform titles
    solr_doc = SolrDocument.new(source_doc={"uniform_titles_display" => [JSON.generate([{"title" => [{"query" => "", "display" => ""}]}])]})
    assert solr_doc.has_uniform_titles?

    solr_doc = SolrDocument.new(source_doc={"new_uniform_title_author_display" => [JSON.generate([{"title" => [{"query" => "", "display" => ""}]}])]})
    assert solr_doc.has_uniform_titles?

    src_doc = {
        "author_display" => "doc_author",
        "uniform_titles_display" => [JSON.generate([{"title" => [{"query" => "q", "display" => "d"}]}])],
        "new_uniform_title_author_display" => [JSON.generate([{"title" => [{"query" => "q2", "display" => "d2"}]}])],
        "uniform_related_works_display" => [JSON.generate([{"title" => [{"query" => "q3", "display" => "d3"}], "author" => "title_author"}])]
    }
    solr_doc = SolrDocument.new(source_doc=src_doc)
    expected_titles = [{"title" => [{"query" => "q", "display" => "d"}]}]
    expected_titles << {"title" => [{"query" => "q2", "display" => "d2"}], "author" => "doc_author"}
    assert solr_doc.get_uniform_titles == expected_titles
  end

  def test_related_works
    empty_doc = SolrDocument.new(source_doc={})
    assert !empty_doc.has_related_works?
    assert empty_doc.get_related_works == []

    solr_doc = SolrDocument.new(source_doc={"uniform_related_works_display" => [JSON.generate([{"title" => [{"query" => "", "display" => ""}]}])]})
    assert solr_doc.has_related_works?

    uniform_related_works_display = [JSON.generate([{"title" => [{"query" => "q3", "display" => "d3"}], "author" => "title_author"}])]
    src_doc = {"uniform_related_works_display" => uniform_related_works_display}
    solr_doc = SolrDocument.new(source_doc=src_doc)
    related_works = [{"title" => [{"query" => "q3", "display" => "d3"}], "author" => "title_author"}]
    assert solr_doc.get_related_works == related_works
  end

  def test_marc_abstract
    marc_display_string = File.read("./test/item_marc.json")
    solr_doc = SolrDocument.new({"marc_display" => marc_display_string})
    assert solr_doc.full_abstract == ["abstract1", "abstract2"]
  end

  def test_item_data
    marc_display_string = File.read("./test/item_marc.json")
    solr_doc = SolrDocument.new({"marc_display" => marc_display_string})
    item_data = solr_doc.item_data

    bookplate1 = item_data.select do |i|
      i.barcode == "barcode1" &&
      i.bookplate_code = "bookplate1" &&
      i.bookplate_url = "http://bookplate1" &&
      i.bookplate_display = "Gift of barcode1"
    end
    assert bookplate1.count == 1

    nodata = item_data.select {|i| i.barcode.nil? && i.location_code.nil?}
    assert nodata.count == 1

    rock = item_data.select {|i| i.location_code == "rock"}
    assert rock.count == 1
  end
end


# describe TableOfContents do

#   describe "#chapters" do

#     it "knows its chapters" do
#       toc = TableOfContents.new([JSON.generate([{"title" => "test title"}])], nil)
#       expect(toc.chapters[0]["title"]).to eq("test title")
#     end

#     it "fills in missing keys as needed" do
#       toc = TableOfContents.new([JSON.generate([{}])], nil)
#       expect(toc.chapters[0]["label"]).to eq("")
#       expect(toc.chapters[0]["indent"]).to eq("")
#       expect(toc.chapters[0]["authors"]).to eq([])
#       expect(toc.chapters[0]["title"]).to eq("")
#       expect(toc.chapters[0]["page"]).to eq("")
#     end

#     it "handles 505 data" do
#       toc = TableOfContents.new(nil, [JSON.generate([{"title" => "test title"}])])
#       expect(toc.chapters[0]["title"]).to eq("test title")
#     end

#     it "defaults to 970 instead of 505" do
#       toc = TableOfContents.new([JSON.generate([{"title" => "970 title"}])], [JSON.generate([{"title" => "505 title"}])])
#       expect(toc.chapters[0]["title"]).to eq("970 title")
#     end

#   end

# end
