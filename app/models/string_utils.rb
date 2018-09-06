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

  def self.strip_punctuation(str)
    return nil if str == nil
    str.chomp(":").chomp(",").chomp(";").strip()
  end

  # Returns the text passed but surrounded by double quotes.
  # Quotes are only added if they are not there.
  def self.surround_quotes(text)
    if text[0] == "'" && text[-1] == "'"
      text = text[1..-2] # drop single quotes
    end
    if text[0] != '"'
      text = '"' + text
    end
    if text[-1] != '"'
      text = text + '"'
    end
    text
  end

  # Returns the text in a format suitable for call number search.
  def self.callnumber_searchable(text)
    text = surround_quotes(text.strip)
    if text[2..7].upcase == "-SIZE "
      # Drop the N-SIZE prefix since we don't index it.
      text = '"' + text[8..-1]
    end
    text
  end
end
