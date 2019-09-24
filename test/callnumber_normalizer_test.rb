require "minitest/autorun"

#
# Skip these tests since they require the NORMALIZE_API_URL
#
# class CallnumberNormalizerTest < Minitest::Test
#   def test_one
#     normalized = CallnumberNormalizer.normalize_one("UA703.A7 40th C84x 1887")
#     assert normalized == "UA 0703000A700 000 000 40THC84X1887"
#   end
#
#   def test_many
#     callnumber1 = "UA703.A7 40th C84x 1887"
#     callnumber2 = "M1630.18.N45 C68x 1975"
#     callnumber3 = "Q916.4 G"
#     callnumbers = [callnumber1, callnumber2, callnumber3]
#
#     normalized = CallnumberNormalizer.normalize_many(callnumbers)
#     normalized1 = normalized.find{|n| n[:callnumber] == callnumber1}.normalized
#     normalized2 = normalized.find{|n| n[:callnumber] == callnumber2}.normalized
#     normalized3 = normalized.find{|n| n[:callnumber] == callnumber3}.normalized
#
#     assert normalized1 == "UA 0703000A700 000 000 40THC84X1887"
#     assert normalized2 == "M  1630180N450C680X1975"
#     assert normalized3 == "Q  0916400G"
#   end
# end
