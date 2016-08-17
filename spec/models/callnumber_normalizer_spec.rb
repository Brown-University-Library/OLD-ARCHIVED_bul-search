require "spec_helper"
require "json"

describe CallnumberNormalizer do
  # Skip these tests by default because they require access
  # to the normalization API via the VPN.
  skip "normalize_one" do
    normalized = CallnumberNormalizer.normalize_one("UA703.A7 40th C84x 1887")
    expect(normalized).to eq("UA 070300A700 000 000 40THC84X1887")
  end

  skip "normalize_many" do
    callnumber1 = "UA703.A7 40th C84x 1887"
    callnumber2 = "M1630.18.N45 C68x 1975"
    callnumber3 = "Q916.4 G"
    callnumbers = [callnumber1, callnumber2, callnumber3]

    normalized = CallnumberNormalizer.normalize(callnumbers)
    normalized1 = normalized.find{|n| n[:callnumber] == callnumber1}.normalized
    normalized2 = normalized.find{|n| n[:callnumber] == callnumber2}.normalized
    normalized3 = normalized.find{|n| n[:callnumber] == callnumber3}.normalized

    expect(normalized1).to eq("UA 070300A700 000 000 40THC84X1887")
    expect(normalized2).to eq("M  163018N450C680X1975")
    expect(normalized3).to eq("Q  091640G")
  end
end
