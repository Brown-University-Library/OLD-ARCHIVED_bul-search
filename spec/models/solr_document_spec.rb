require "spec_helper"
require "json"

describe SolrDocument do

  describe "#has_toc?" do

    it "handles empty solr data" do
      solrdoc = SolrDocument.new(source_doc={})
      expect(solrdoc.has_toc?).to be false
    end

    it "handles solr data with no toc" do
      solrdoc = SolrDocument.new(source_doc={"id" => "b123456"})
      expect(solrdoc.has_toc?).to be false
    end

    it "handles 505 toc" do
      solrdoc = SolrDocument.new(source_doc={"toc_display" => ["test toc"]})
      expect(solrdoc.has_toc?).to be true
    end

    it "handles 970 toc" do
      solrdoc = SolrDocument.new(source_doc={"toc_970_display" => ["test toc"]})
      expect(solrdoc.has_toc?).to be true
    end

    it "handles both kinds of toc" do
      solrdoc = SolrDocument.new(source_doc={"toc_display" => ["test 505 toc"], "toc_970_display" => ["test 970 toc"]})
      expect(solrdoc.has_toc?).to be true
    end

  end

  describe "#get_toc" do

      it "returns TableOfContents object" do
        solrdoc = SolrDocument.new(source_doc={"toc_970_display" => [JSON.generate([])]})
        expect(solrdoc.get_toc.chapters).to eq([])
      end

  end

end

describe TableOfContents do

  describe "#chapters" do

    it "knows its chapters" do
      toc = TableOfContents.new([JSON.generate([{"title" => "test title"}])], nil)
      expect(toc.chapters[0]["title"]).to eq("test title")
    end

    it "fills in missing keys as needed" do
      toc = TableOfContents.new([JSON.generate([{}])], nil)
      expect(toc.chapters[0]["label"]).to eq("")
      expect(toc.chapters[0]["indent"]).to eq("")
      expect(toc.chapters[0]["authors"]).to eq([])
      expect(toc.chapters[0]["title"]).to eq("")
      expect(toc.chapters[0]["page"]).to eq("")
    end

    it "handles 505 data" do
      toc = TableOfContents.new(nil, [JSON.generate([{"title" => "test title"}])])
      expect(toc.chapters[0]["title"]).to eq("test title")
    end

    it "defaults to 970 instead of 505" do
      toc = TableOfContents.new([JSON.generate([{"title" => "970 title"}])], [JSON.generate([{"title" => "505 title"}])])
      expect(toc.chapters[0]["title"]).to eq("970 title")
    end

  end

end
