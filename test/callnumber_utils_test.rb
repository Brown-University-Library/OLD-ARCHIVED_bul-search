require "minitest/autorun"
class CallnumberUtilsTest < Minitest::Test
  def test_tokenizer
    tokenized = CallnumberUtils::tokenized("ab123")
    assert tokenized == "AB|123"

    tokenized = CallnumberUtils::tokenized("ab 123")
    assert tokenized == "AB|123"

    tokenized = CallnumberUtils::tokenized("ab .123")
    assert tokenized == "AB|123"
  end
end
