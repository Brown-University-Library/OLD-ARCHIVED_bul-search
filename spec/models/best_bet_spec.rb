require "spec_helper"
require "json"

describe BestBet do
  it "parses course reserves" do
    expect(BestBet.is_course_number?("ABC 0991")).to be(true)
    expect(BestBet.is_course_number?("ABCD 0991")).to be(true)
    expect(BestBet.is_course_number?("ABCDE 0991")).to be(true)

    expect(BestBet.is_course_number?("A2 0991")).to be(false)
    expect(BestBet.is_course_number?("A2CD 0991")).to be(false)
  end
end
