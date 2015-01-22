require "spec_helper"

def imprint
    <<-xml
    <record>
      <datafield tag="245" ind1="1" ind2="0">
        <subfield code="a">As the eye moves ...</subfield>
        <subfield code="c">a sculpture by Henry Moore. Photos. by David Finn. Words by Donald Hall.</subfield>
      </datafield>
      <datafield tag="500" ind1=" " ind2=" ">
        <subfield code="a">Photos of Moore&apos;s Bridge-Prop.</subfield>
      </datafield>
      <datafield tag="650" ind1=" " ind2=" ">
        <subfield code="a">Photos of Moore&apos;s Bridge-Prop.</subfield>
      </datafield>
    </record>
    xml
end

describe MarcHelper do

  before(:each) do
    SolrDocument.extension_parameters[:marc_format_type]   = :marcxml
    @solrdoc = SolrDocument.new(:marc_display => imprint)
  end

  # describe "#marc_display" do

  #   it "renders the imprint" do
  #     val = helper.marc_display(@solrdoc, "imprint")
  #     expect(val).to eq "stuff"
  #   end

  # end

  describe "#marc_display_tag" do
    it "handles a note" do
      val = helper.marc_display_tag(@solrdoc, "500")[0]
      expect(val).to include("Photos of Moore")
    end
  end


end