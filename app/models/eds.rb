require "./lib/http_json.rb"
require "./app/models/eds_results.rb"
require "./app/helpers/application_helper.rb"
require 'ebsco/eds'

class Eds

  # RV:Y peer reviewed
  # FT: Y full text only
  DEFAULT_LIMITERS = ["RV:Y", "FT:Y"]
  DEFAULT_LIMITERS_QS = "&cli0=RV&clv0=Y&cli1=FT&clv1=Y"
  DEFAULT_EXPAND_LIMITERS_QS = "&cli0=RV&clv0=N&cli1=FT&clv1=N"

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
    @session = get_session(@credentials)
  end

  def get_session(credentials)
    if ENV["EDS_CACHE_SESSION"] != "true"
      return new_session(credentials, "no cache")
    end

    if credentials[:guest]
      Rails.logger.info "EDS_SESSION: guest session"
      return Rails.cache.fetch("eds_guest_session", expires_in: 2.minute) do
        begin
          new_session(credentials, "new guest session")
        rescue Exception => e
          Rails.logger.error "EDS_SESSION: Could not get new guest session for EDS: #{e.to_s}"
          nil
        end
      end
    end

    Rails.logger.info "EDS_SESSION: auth session"
    return Rails.cache.fetch("eds_auth_session", expires_in: 2.minute) do
      begin
        new_session(credentials, "new auth session")
      rescue Exception => e
        Rails.logger.error "EDS_SESSION: Could not get new auth session for EDS: #{e.to_s}"
        nil
      end
    end
  end

  def new_session(credentials, log_msg)
    beginTime = Time.now
    session = EBSCO::EDS::Session.new(credentials)
    elapsed_ms = ((Time.now - beginTime) * 1000).to_i
    Rails.logger.info "EDS_SESSION: #{log_msg}, #{elapsed_ms}ms"
    session
  end

  def self.ebsco_base_url(query, delimiters = true)
    url = "http://search.ebscohost.com/login.aspx"
    url += "?direct=true&site=eds-live&authtype=ip,sso&custid=rock&groupid=main&profid=eds"
    if delimiters
      url += DEFAULT_LIMITERS_QS
    else
      url += DEFAULT_EXPAND_LIMITERS_QS
    end
    if query != nil
      url += "&bquery=#{query}"
    end
  end

  def self.native_url(query, trusted_ip, delimiters = true)
    url = self.ebsco_base_url(query, delimiters) + "&type=0"
    if !trusted_ip
      # Force users *not on campus* to authenticate through Shibboleth,
      # otherwise EBSCO will ask them to authenticate with them and we
      # don't want that.
      url = "https://login.revproxy.brown.edu/login?url=" + url
    end
    url
  end

  def self.native_expanded_url(query, trusted_ip)
    native_url(query, trusted_ip, false)
  end

  def self.native_advanced_url(query, trusted_ip)
    url = self.ebsco_base_url(query) + "&type=1"
    if !trusted_ip
      # Ditto what I said for native_url()
      url = "https://login.revproxy.brown.edu/login?url=" + url
    end
    url
  end

  def self.native_newspapers_url(query, trusted_ip)
    # TODO: Apply filter for newspaper
    return self.native_url(query, trusted_ip)
  end

  def search(text)
    if text.empty?
      return EdsResults.new([], [], 0)
    end
    # Notice that we don't pass an explicit parameter to request
    # full text only because API profile has been configured in
    # the EBSCO Admin tool to return full text only by default.
    options = {
      query: text,
      results_per_page: 5,
      highlight: false,
      limiters: DEFAULT_LIMITERS
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
      limiters: DEFAULT_LIMITERS
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
