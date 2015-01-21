require "spec_helper"

def marc_from_xml(string)
  reader = MARC::XMLReader.new(StringIO.new(string))
  reader.each {|rec| return rec }
end

def imprint
    <<-xml
    <record>
      <leader>01146nam a2200313   4500</leader>
      <datafield tag="245" ind1="1" ind2="0">
        <subfield code="a">As the eye moves ...</subfield>
        <subfield code="c">a sculpture by Henry Moore. Photos. by David Finn. Words by Donald Hall.</subfield>
      </datafield>
      <datafield tag="500" ind1=" " ind2=" ">
        <subfield code="a">Photos of Moore&apos;s Bridge-Prop.</subfield>
      </datafield>
    </record>
    xml
end

require 'solr_document'

def mock_doc(marcxml)
  require 'byebug'; byebug
  mock_class = SolrDocument.new()
  mock_class.new(:marc => marcxml)
end

describe MarcHelper do
  describe "#marc_display" do

    it "renders the imprint" do
      document = SolrDocument.new(:marc => imprint)
      val = helper.marc_display(document, "imprint")
      expect(val).to eq "stuff"
    end

  end

  describe "#marc_display_tag" do
    it "handles a note" do
      document = SolrDocument.new(:marc => imprint)
      val = helper.marc_display_tag(document, "500")
      expect(val).to eq "stuff"
    end
  end


end