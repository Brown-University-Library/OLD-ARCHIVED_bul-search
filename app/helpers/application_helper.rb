module ApplicationHelper
  def html_title_line(title, text)
    return "" if text.blank?
    # This weird concatenation is to make sure Rails
    # HTML encodes title+text but not the <br/>
    "".html_safe + ("#{title}: #{text}") + "<br/>".html_safe
  end
end
