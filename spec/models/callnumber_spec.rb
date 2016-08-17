require "spec_helper"
require "json"

describe Callnumber do
  it "parses call numbers LOC class/subclass correctly" do
    lc_class, lc_subclass = Callnumber.loc_class("UA23. .M58 2000")
    expect(lc_class).to eq("UA")
    expect(lc_subclass).to eq("UA23")

    lc_class, lc_subclass = Callnumber.loc_class("PS3562.U548 W47 2000")
    expect(lc_class).to eq("PS")
    expect(lc_subclass).to eq("PS3562")

    lc_class, lc_subclass = Callnumber.loc_class("UA23 .O84x 2000")
    expect(lc_class).to eq("UA")
    expect(lc_subclass).to eq("UA23")

    lc_class, lc_subclass = Callnumber.loc_class("UA23 .M478223x 2000")
    expect(lc_class).to eq("UA")
    expect(lc_subclass).to eq("UA23")

    lc_class, lc_subclass = Callnumber.loc_class("JK216 .T713 2000b")
    expect(lc_class).to eq("JK")
    expect(lc_subclass).to eq("JK216")

    lc_class, lc_subclass = Callnumber.loc_class("JK7125 1907 .A33")
    expect(lc_class).to eq("JK")
    expect(lc_subclass).to eq("JK7125")

    # 1 letter in classification
    lc_class, lc_subclass = Callnumber.loc_class("E99.S28 W67 2010")
    expect(lc_class).to eq("E")
    expect(lc_subclass).to eq("E99")

    # 3 letters in classification
    lc_class, lc_subclass = Callnumber.loc_class("DAW1024 X67 2010")
    expect(lc_class).to eq("DAW")
    expect(lc_subclass).to eq("DAW1024")

    # Oversize item (1-SIZE prefix)
    lc_class, lc_subclass = Callnumber.loc_class("1-SIZE PS3523.O82 Z98 E54 1999")
    expect(lc_class).to eq("PS")
    expect(lc_subclass).to eq("PS3523")

    # Starts with a year
    # This is for weird items that have a callnumber
    # at the item level (field 945a), for example
    # https://search.library.brown.edu/catalog/b3339797
    lc_class, lc_subclass = Callnumber.loc_class("2001 R845 P38f")
    expect(lc_class).to eq("R")
    expect(lc_subclass).to eq("R845")
  end
end
