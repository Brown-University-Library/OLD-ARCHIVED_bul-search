module ApplicationHelper
  def html_title_line(title, text)
    return "" if text.blank?
    # This weird concatenation is to make sure Rails
    # HTML encodes title+text but not the <br/>
    "".html_safe + ("#{title}: #{text}") + "<br/>".html_safe
  end

  # An enhanced version of html_safe that takes into account characters
  # that cause issues when embedded on a JavaScript string.
  def js_safe(text)
    return "" if text == nil
    text = text.gsub("\\", "%5C")
    text = text.gsub('"', '\"')
    text.html_safe
  end

  # An enhanced version of html_safe that works with arrays of strings
  # and takes into account (via js_safe) characters that cause issues
  # when embedded on a JavaScript string.
  def js_safe_strings(array)
    return "" if array == nil
    text = "[" + array.map {|x| '"' + js_safe(x) + '"'}.join(",") + "]"
    text.html_safe
  end

  # We use this to generate a new token every day and embed this
  # value in our forms and prevent spammers from reusing sessions
  # for more than one day. We should eventually track this on a
  # per request basis rather than on a daily basis but this would
  # do for now.
  def daily_token
    if ENV["DAILY_TOKEN"]
      eval(ENV["DAILY_TOKEN"])
    else
      (Math.tan(500-Date.today.yday).abs * 10000000).to_i.to_s[1..-1]
    end
  end

  def request_token
    (Random.new.rand * 10000).to_i.to_s
  end

  def spam_check?
    ENV["SPAM_CHECK"] == "yes"
  end

  def trusted_ips
    (ENV["TRUSTED_IPS"] || "").chomp.split(",")
  end

  def trusted_ip?(ip)
    return false if ip == nil
    trusted_ips.each do |trusted_value|
      return true if ip.start_with?(trusted_value)
    end
    false
  end

  def google_form_url()
    url = "https://docs.google.com/forms/d/e/1FAIpQLSfJzCWiV06MFF8mkJ7uhhnv_FeWAoKdlxIXMHAAwn7LIv4_UA/viewform?usp=pp_url&entry.707592340&entry.1473753199&entry.1930188522&entry.1267373353&entry.1478665067="
    if defined?(request) && request != nil
      josiah_url = CGI.escape(request.url)
      url += josiah_url
    end
    url
  end

  def my_library_account_url()
    ENV["MY_LIBRARY_ACCOUNT_URL"]
  end
end
