require "spec_helper"

def general_note
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

def note_multiple_values
  <<-xml
  <record>
    <datafield tag="245">
      <subfield code="a">My title</subfield>
    </datafield>
    <datafield tag="507">
      <subfield code="a">Less</subfield>
      <subfield code="b">Moore</subfield>
    </datafield>
    <datafield tag="507">
      <subfield code="a">Medium</subfield>
    </datafield>
  </record>
  xml
end

describe MarcHelper do

  before(:each) do
    SolrDocument.extension_parameters[:marc_format_type]   = :marcxml
    @solrdoc = SolrDocument.new(:marc_display => general_note)
    @solrdoc2 = SolrDocument.new(:marc_display => note_multiple_values)
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

  describe "get_link_text" do
    it "works" do
      val = helper.get_link_text({'author' => ' author 1', 'title' => 'title 1 '})
      expect(val).to eq('author 1. title 1')
      val = helper.get_link_text({'title' => 'title 1'})
      expect(val).to eq('title 1')
    end
  end

  describe "get_search_params" do
    it "gets correct search params" do
      params = helper.get_search_params("title", "title query")
      expect(params).to eq({:controller=>"catalog", :action=>"index", :search_field=>"title", :q=>"title query"})
    end
  end

  describe "get_advanced_search_uniform_title_params" do
    it "gets correct params" do
      params = helper.get_advanced_search_uniform_title_params("title query", "author query")
      expect(params).to eq({:controller=>"catalog", :action=>"index", :search_field=>"advanced",
                            :title=>"title query", :author=>"author query"})
    end

    it "handles nil author" do
      params = helper.get_advanced_search_uniform_title_params("title query", nil)
      expect(params).to eq({:controller=>"catalog", :action=>"index", :search_field=>"advanced",
                            :title=>"title query"})
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

    it "renders multiple and repeating notes partial with the expected locals" do
      note_display = [{:label => "Scale of Material", :values => ["Less Moore", "Medium"]}]
       #http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
       expect(helper).to receive(:render).with(
         {
           :partial=>'catalog/record/notes',
           :locals=>{:note_display => note_display}
         }
       )
       helper.render_record_notes(@solrdoc2)
    end

  end

end
