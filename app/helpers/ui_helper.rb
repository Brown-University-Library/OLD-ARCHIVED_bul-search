module UiHelper
  # Removes Solr specific syntax used in some searches since
  # we don't want to clutter the UI with this information.
  def clean_search_term(term)
    return nil if term == nil
    token1 = "bookplate_code_ss:/"
    token2 = ".*/"
    if term.start_with?(token1) && term.end_with?(token2)
      clean = term.gsub(token1, "")
      clean = clean.gsub(token2, "")
      clean = clean
    else
      clean = term
    end
    clean
  end

  def truncate_text(text, max_length)
    if text == nil
      return ""
    end
    if text.length > max_length
      return text[0..max_length] + "..."
    end
    text
  end
end
