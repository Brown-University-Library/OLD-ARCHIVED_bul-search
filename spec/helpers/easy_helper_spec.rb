require "spec_helper"

describe EasyHelper do

  describe "worldcat_search" do
    it "escapes" do
      val = helper.worldcat_search("<&$!#@>!badquery")
      expect(val).to eq("http://worldcat.org.revproxy.brown.edu/search?&q=%3C%26%24%21%23%40%3E%21badquery")
    end
  end

  describe "bdr_search" do
    it "escapes" do
      ENV["BDR_SEARCH_URL"] = "https://repository.library.brown.edu/studio/search/"
      val = helper.bdr_search("<&$!#@>!badquery")
      expect(val).to eq("https://repository.library.brown.edu/studio/search/?q=%3C%26%24%21%23%40%3E%21badquery")
    end
  end

end
