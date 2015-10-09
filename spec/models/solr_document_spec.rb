require "spec_helper"
require "json"

describe SolrDocument do

  describe "#to_sms_text" do

    def stub_get_location_text_nil
      SolrDocument.class_eval do
        def get_location_text
        end
      end
    end

    it "knows the url to hit for location" do
      solrdoc = SolrDocument.new(source_doc={"id" => "b123456"})
      expect(solrdoc.location_data_url).to end_with("bibutils/bib/b123456")
    end

    it "can parse the location text from an availability response" do
      solrdoc = SolrDocument.new(source_doc={"id" => "b123456"})
      response = ""
      expect(solrdoc.parse_location_text_from_availability_response(response)).to be nil
      response = nil
      expect(solrdoc.parse_location_text_from_availability_response(response)).to be nil
      response = JSON.generate({})
      expect(solrdoc.parse_location_text_from_availability_response(response)).to be nil
      response = JSON.generate({"items" => [{"location" => "ROCK"}]})
      expect(solrdoc.parse_location_text_from_availability_response(response)).to eq("Location: ROCK")
      response = JSON.generate({"items" => [{"location" => "ROCK", "shelf" => {"aisle" => "27A", "floor" => "4"}}]})
      expect(solrdoc.parse_location_text_from_availability_response(response)).to eq("Location: ROCK -- Level 4, Aisle 27A")
    end

    it "creates basic sms text" do
      stub_get_location_text_nil
      solrdoc = SolrDocument.new(source_doc={"title_display" => ["test title"]})
      expect(solrdoc.to_sms_text).to eq("test title")
    end

    it "creates sms text with callnumber" do
      stub_get_location_text_nil
      solrdoc = SolrDocument.new(source_doc={"title_display" => ["test title"], "callnumber_t" => ["AB12 .C3"]})
      expect(solrdoc.to_sms_text).to eq("test title\nAB12 .C3")
    end

    it "creates sms text with location info" do
      SolrDocument.class_eval do
        def get_location_text
          "Location: Rock"
        end
      end
      solrdoc = SolrDocument.new(source_doc={"title_display" => ["test title"]})
      expect(solrdoc.to_sms_text).to eq("test title\nLocation: Rock")
    end
  end

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

      it "returns TableOfContents object with 970 info" do
        solrdoc = SolrDocument.new(source_doc={"toc_970_display" => [JSON.generate([{"title" => "970"}])]})
        expect(solrdoc.get_toc.chapters[0]["title"]).to eq("970")
      end

      it "returns TableOfContents object with 505 info" do
        solrdoc = SolrDocument.new(source_doc={"toc_display" => [JSON.generate([{"title" => "505"}])]})
        expect(solrdoc.get_toc.chapters[0]["title"]).to eq("505")
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
