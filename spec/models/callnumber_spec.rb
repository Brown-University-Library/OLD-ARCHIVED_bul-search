require "spec_helper"
require "json"

describe Callnumber do
  describe "#parse" do
    it "parses call numbers correctly" do
      item = Callnumber.new("UA23. .M58 2000")
      expect(item.lc_class).to eq("UA")
      expect(item.lc_subclass).to eq("UA23")

      item = Callnumber.new("PS3562.U548 W47 2000")
      expect(item.lc_class).to eq("PS")
      expect(item.lc_subclass).to eq("PS3562")

      item = Callnumber.new("UA23 .O84x 2000")
      expect(item.lc_class).to eq("UA")
      expect(item.lc_subclass).to eq("UA23")

      item = Callnumber.new("UA23 .M478223x 2000")
      expect(item.lc_class).to eq("UA")
      expect(item.lc_subclass).to eq("UA23")

      item = Callnumber.new("JK216 .T713 2000b")
      expect(item.lc_class).to eq("JK")
      expect(item.lc_subclass).to eq("JK216")

      item = Callnumber.new("JK7125 1907 .A33")
      expect(item.lc_class).to eq("JK")
      expect(item.lc_subclass).to eq("JK7125")

      # 1 letter in classification
      item = Callnumber.new("E99.S28 W67 2010")
      expect(item.lc_class).to eq("E")
      expect(item.lc_subclass).to eq("E99")

      # 3 letters in classification
      item = Callnumber.new("DAW1024 X67 2010")
      expect(item.lc_class).to eq("DAW")
      expect(item.lc_subclass).to eq("DAW1024")

      # Oversize item (1-SIZE prefix)
      item = Callnumber.new("1-SIZE PS3523.O82 Z98 E54 1999")
      expect(item.lc_class).to eq("PS")
      expect(item.lc_subclass).to eq("PS3523")

      # Starts with a year
      # This is for weird items that have a callnumber
      # at the item level (field 945a), for example
      # https://search.library.brown.edu/catalog/b3339797
      item = Callnumber.new("2001 R845 P38f")
      expect(item.lc_class).to eq("R")
      expect(item.lc_subclass).to eq("R845")
    end
  end
end
