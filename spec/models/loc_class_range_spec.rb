require "spec_helper"
require "json"

describe LocClassRange  do
  it "finds a range" do
    loc_range = LocClassRange.new
    range = loc_range.find_range("B721")
    expect(range[:begin] <= "B721").to be true
  end

  it "finds next range" do
    loc_range = LocClassRange.new
    range = loc_range.find_next("B721")
    expect(range[:begin]).to eq("B770")
  end

  it "finds previous range" do
    loc_range = LocClassRange.new
    range = loc_range.find_next("B770")
    expect(range[:begin]).to eq("B790")
  end
end
