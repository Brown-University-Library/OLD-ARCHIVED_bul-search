require 'spec_helper'

describe BdrDisplay do
  ENV['BDR_ITEM_API_URL'] = 'http://localhost/api/'
  let(:item) {BdrSolrDocument.new(pid: "bdr:1234") }

  it "should build the proper item API URL" do
    expect(item.item_api_url).to eq 'http://localhost/api/bdr:1234/'
  end

end