class StringUtils
  def self.clean_join(a, b, c = nil)
    ab = ""
    case
      when a != nil && b != nil
        ab = "#{a.strip} #{b.strip}"
      when a != nil && b == nil
        ab = "#{a.strip}"
      when a == nil && b != nil
        ab = "#{b.strip}"
    end
    if c != nil
      ab = self.clean_join(ab, c)
    end
    ab.strip
  end

  def self.cjk?(str)
    # Source https://stackoverflow.com/a/4681577/446681
    #   Han - Chinese
    #   Katakana - Japanese
    #   Hiragana - Japanese
    #   Hangul - Korean
    !!(str =~ /\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/)
  end

  def self.strip_punctuation(str)
    return nil if str == nil
    str.chomp(":").chomp(",").chomp(";").strip()
  end

  def self.truncate(str, length)
    (str || "")[0..length]
  end
end
