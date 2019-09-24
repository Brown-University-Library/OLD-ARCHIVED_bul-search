require "minitest/autorun"
class MarcHelperTest < Minitest::Test
  include MarcHelper

  def general_note()
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

  def note_multiple_values()
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

  def test_imprint
    SolrDocument.extension_parameters[:marc_format_type] = :marcxml
    solr_doc = SolrDocument.new(:marc_display => general_note())
    assert marc_display(solr_doc, "imprint") == "A publisher"
  end

  def test_note
    SolrDocument.extension_parameters[:marc_format_type] = :marcxml
    solr_doc = SolrDocument.new(:marc_display => general_note())
    assert marc_display_tag(solr_doc, "500")[0].include?("Photos of Moore")
  end

  def test_get_link_text
    text = get_link_text({'author' => ' author 1', 'title' => 'title 1 '})
    assert text == 'author 1. title 1'
    text = get_link_text({'title' => 'title 1'})
    assert text == 'title 1'
  end

  def test_search_params
    params = get_search_params("title", "title query")
    assert params == {:controller=>"catalog", :action=>"index", :search_field=>"title", :q=>"title query"}
  end

  def test_advanced_search_uniform_title_params
    params = get_advanced_search_uniform_title_params("title query", "author query")
    assert params == {:controller=>"catalog", :action=>"index", :search_field=>"advanced", :title=>"title query", :author=>"author query"}

    # handles nil author
    params = get_advanced_search_uniform_title_params("title query", nil)
    assert params == {:controller=>"catalog", :action=>"index", :search_field=>"advanced", :title=>"title query"}
  end

  def test_millennium_notes
    SolrDocument.extension_parameters[:marc_format_type] = :marcxml

    solr_doc = SolrDocument.new(:marc_display => general_note())
    note_display = [{:label => "Note", :values => ["Photos of Moore"]}]
    assert millenium_notes(solr_doc) == note_display

    solr_doc = SolrDocument.new(:marc_display => note_multiple_values())
    note_display = [{:label => "Scale of Material", :values => ["Less Moore", "Medium"]}]
    assert millenium_notes(solr_doc) == note_display
  end
end
