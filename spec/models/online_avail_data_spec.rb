require "spec_helper"
require "json"

describe OnlineAvailData do
  it "handled classic Josiah URLs properly" do
    data = OnlineAvailData.new("http://josiah.brown.edu/record=b7506363", "notes", "materials")
    expect(data.url).to eq("http://search.library.brown.edu/catalog/b7506363")
  end

  it "handled non-Josiah URLs properly" do
    data = OnlineAvailData.new("http://whatever.org/123?q=qwerty", "notes", "materials")
    expect(data.url).to eq("http://whatever.org/123?q=qwerty")
  end
end
