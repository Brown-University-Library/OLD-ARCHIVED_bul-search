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
    @session = get_session(@credentials, guest)
  end

  def get_session(credentials, guest)
    if ENV["EDS_CACHE_SESSION"] != "true"
      # Rails.logger.info "EDS_SESSION: == NO CACHE == #{Time.now}"
      return EBSCO::EDS::Session.new(credentials)
    end

    if guest
      Rails.logger.info "EDS_SESSION: == GUEST SESSION == #{Time.now}"
      return Rails.cache.fetch("eds_guest_session", expires_in: 2.minute) do
        begin
          Rails.logger.info "EDS_SESSION: == NEW GUEST SESSION == #{Time.now}"
          EBSCO::EDS::Session.new(credentials)
        rescue Exception => e
          Rails.logger.error "EDS_SESSION: Could not get new guest session for EDS: #{e.to_s}"
          nil
        end
      end
    end

    Rails.logger.info "EDS_SESSION: == AUTH SESSION == #{Time.now}"
    return Rails.cache.fetch("eds_auth_session", expires_in: 2.minute) do
      begin
        Rails.logger.info "EDS_SESSION: == NEW AUTH SESSION == #{Time.now}"
        EBSCO::EDS::Session.new(credentials)
      rescue Exception => e
        Rails.logger.error "EDS_SESSION: Could not get new auth session for EDS: #{e.to_s}"
        nil
      end
    end
  end

  def self.native_url(query, trusted_ip)
    url = "http://search.ebscohost.com/login.aspx?direct=true&bquery=#{query}&type=0&site=eds-live&authtype=ip&custid=rock&groupid=main&profid=eds"
    if !trusted_ip
      # Force users *not on campus* to authenticate through Shibboleth,
      # otherwise EBSCO will ask them to authenticate with them and we
      # don't want that.
      url = "https://login.revproxy.brown.edu/login?url=" + url
    end
    url
  end

  def self.native_advanced_url(query, trusted_ip)
    url = "http://search.ebscohost.com/login.aspx?direct=true&bquery=#{query}&type=1&site=eds-live&authtype=ip&custid=rock&groupid=main&profid=eds"
    if !trusted_ip
      # Ditto what I said for native_url()
      url = "https://login.revproxy.brown.edu/login?url=" + url
    end
    url
  end

  def self.native_newspapers_url(query, trusted_ip)
    # TODO: Apply filter for newspaper
    url = "http://search.ebscohost.com/login.aspx?direct=true&bquery=#{query}&type=1&site=eds-live&authtype=ip&custid=rock&groupid=main&profid=eds"
    if !trusted_ip
      # Ditto what I said for native_url()
      url = "https://login.revproxy.brown.edu/login?url=" + url
    end
    url
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
