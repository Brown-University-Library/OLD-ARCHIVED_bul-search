require "spec_helper"

def imprint
    <<-xml
    <record>
      <datafield tag="245">
        <subfield code="a">As the eye moves ...</subfield>
        <subfield code="c">a sculpture by Henry Moore. Photos. by David Finn. Words by Donald Hall.</subfield>
      </datafield>
      <datafield tag="260">
        <subfield code="a">A publisher</subfield>
      </datafield>
      <datafield tag="500">
        <subfield code="a">Photos of Moore</subfield>
      </datafield>
    </record>
    xml
end

describe MarcHelper do

  before(:each) do
    SolrDocument.extension_parameters[:marc_format_type]   = :marcxml
    @solrdoc = SolrDocument.new(:marc_display => imprint)
  end

  describe "#marc_display" do

    it "renders the imprint" do
      val = helper.marc_display(@solrdoc, "imprint")
      expect(val).to eq "A publisher"
    end

  end

  describe "#marc_display_tag" do
    it "handles a note" do
      val = helper.marc_display_tag(@solrdoc, "500")[0]
      expect(val).to include("Photos of Moore")
    end
  end

  describe "#render_record_notes" do
    it "renders the right note partial with the expected locals" do
      note_display = [{:label => "Note", :values => ["Photos of Moore"]}]
      #http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
      expect(helper).to receive(:render).with(
        {
          :partial=>'catalog/record/notes',
          :locals=>{:note_display => note_display}
        }
      )
      helper.render_record_notes(@solrdoc)
    end
  end


end