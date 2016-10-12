module ApplicationHelper
  def html_title_line(title, text)
    return "" if text.blank?
    # This weird concatenation is to make sure Rails
    # HTML encodes title+text but not the <br/>
    "".html_safe + ("#{title}: #{text}") + "<br/>".html_safe
  end

  # We use this to generate a new token every day and embed this
  # value in our forms and prevent spammers from reusing sessions
  # for more than one day. We should eventually track this on a
  # per request basis rather than on a daily basis but this would
  # do for now.
  def daily_token
    (Math.tan(500-Date.today.yday).abs * 10000000).to_i.to_s[1..-1]
  end

  def request_token
    (Random.new.rand * 10000).to_i.to_s
  end

  def spam_check?
    ENV["SPAM_CHECK"] != nil
  end
end
