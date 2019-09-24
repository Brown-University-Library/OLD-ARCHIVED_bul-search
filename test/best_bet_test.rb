require "minitest/autorun"
class BestBetTest < Minitest::Test
  def test_parse
    assert BestBet.is_course_number?("ABC 0991")
    assert BestBet.is_course_number?("ABCD 0991")
    assert BestBet.is_course_number?("ABCDE 0991")
    assert !BestBet.is_course_number?("A2 0991")
    assert !BestBet.is_course_number?("A2CD 0991")
  end
end
