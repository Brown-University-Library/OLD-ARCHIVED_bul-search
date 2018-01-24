class StringUtils
  def self.clean_join(a, b)
    case
      when a != nil && b != nil
        "#{a} #{b}"
      when a != nil && b == nil
        "#{a}"
      when a == nil && b != nil
        "#{b}"
      else
        ""
    end
  end

  def self.strip_punctuation(str)
    return nil if str == nil
    str.chomp(":").chomp(",").chomp(";").strip()
  end
end
