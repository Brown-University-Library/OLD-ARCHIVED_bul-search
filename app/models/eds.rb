require "./lib/http_json.rb"
require "./app/models/eds_results.rb"
require "./app/helpers/application_helper.rb"
require 'ebsco/eds'

class Eds
  def initialize(guest_user, trusted_ip)
    if trusted_ip
      guest = false
    else
      guest = !trusted_ip
    end
    # TODO: make the credentials a parameter rather than ENV values
    @profile_id = ENV["EDS_PROFILE_ID"]
    @credentials = {
      user: ENV["EDS_USER_ID"],
      pass: ENV["EDS_PASSWORD"],
      profile: @profile_id,
      guest: guest
    }
    @session = EBSCO::EDS::Session.new(@credentials)
  end

  def self.native_url(query, trusted_ip)
    url = "http://search.ebscohost.com/login.aspx?direct=true&bquery=#{query}&type=0&site=eds-live&authtype=ip&custid=rock&groupid=main&profid=eds"
    if !trusted_ip
      # Force users *not on campus* to authenticate through Shibboleth,
      # otherwise EBSCO will ask them to authenticate with them and we
      # don't want that.
      url = "https://login.revproxy.brown.edu/login?url=" + url
    end
  end

  def self.native_advanced_url(query, trusted_ip)
    url = "http://search.ebscohost.com/login.aspx?direct=true&bquery=#{query}&type=1&site=eds-live&authtype=ip&custid=rock&groupid=main&profid=eds"
    if !trusted_ip
      # Ditto what I said for native_url()
      url = "https://login.revproxy.brown.edu/login?url=" + url
    end
  end

  def search(text)
    if text.empty?
      return EdsResults.new([], [], 0)
    end
    options = {
      query: text,
      results_per_page: 5,
      highlight: false,
      limiters: ["RV:y"]      # peer-reviewed only (yes)
    }
    results = @session.search(options)
    # results = @session.simple_search(text)
    EdsResults.from_response(results)
  end

  def search_raw(text)
    if text.empty?
      return "[]"
    end
    options = {
      query: text,
      results_per_page: 5,
      highlight: false,
      limiters: ["RV:y"]      # peer-reviewed only (yes)
    }
    results = @session.search(options)
    results.records
  end

  def newspapers_count(text)
    if text.empty?
      return 0
    end
    options = {
      query: text,
      results_per_page: 5,
      highlight: false
    }
    # TODO: we should probably do this as part of the normal
    # search so we don't issue the same search twice.
    results = @session.search(options)
    @session.add_facet('SourceType', 'News')
    news = @session.search(options)
    if news && news.stat_total_hits
      return news.stat_total_hits
    end
    return 0
  end
end
