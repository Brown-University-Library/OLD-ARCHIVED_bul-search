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

  def self.is_solr_regex?(code)
    return false if code == nil
    code.start_with?("/") && code.end_with?("/")
  end

  def self.solr_safe_regex(value)
    safe_value = ""
    value.each_char do |c|
      case
        when (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") ||
          (c >= "0" && c <= "9") || c == " " || c == "_"
          safe_value += c
        when c == "+" || c == "." || c == "*" || c == "/" || c == "|"
          safe_value += "\\" + c
        else
          safe_value += "."
      end
    end
    safe_value
  end
end
