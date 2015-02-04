require "spec_helper"

describe BdrHelper do

  before(:each) do
    @with_genre = SolrDocument.new(:genre => ['theses'])
    @no_genre = SolrDocument.new(:genre => nil)
    @contrib_date = SolrDocument.new(
      :contributor_display => ['Smith, Joe'], :copyrightDate => '2010-01-01T00:00:00Z'
    )
    @no_contrib__with_date = SolrDocument.new(
      :copyrightDate => '2010-01'
    )
  end

  describe "#bdr_render_index_item_subheading" do
    it "renders contributor and date" do
      val = helper.bdr_render_index_item_subheading(@contrib_date)
      expect(val).not_to be_empty
      expect(val).to include('Smith, Joe. 2010')
    end
    it "renders date" do
      val = helper.bdr_render_index_item_subheading(@no_contrib__with_date)
      expect(val).not_to be_empty
      expect(val).to include('2010')
    end
    it "does nothing with empty fields" do
      val = helper.bdr_render_index_item_subheading(SolrDocument.new())
      expect(val).to be_nil
    end
  end

  describe "#render_index_format_subheading" do
    it "renders a single format" do
      val = helper.render_index_format_subheading(@with_genre)
      expect(val).to include('div')
      expect(val).to include('theses')
    end
    it "renders multiple formats" do
      @with_genre[:genre].push('readings')
      val = helper.render_index_format_subheading(@with_genre)
      expect(val).to include('div')
      expect(val).to include('theses')
      expect(val).to include('readings')
    end
    it "renders no format properly" do
      val = helper.render_index_format_subheading(@no_genre)
      expect(val).to be_nil
    end
  end

end