require "./lib/http_json.rb"
require "./app/models/eds_results.rb"
require "./app/helpers/application_helper.rb"
require 'ebsco/eds'

class Eds
  include ApplicationHelper

  def initialize(ip = nil)
    # TODO: make the credentials a parameter rather than ENV values
    guest = !trusted_ip?(ip)
    @profile_id = ENV["EDS_PROFILE_ID"]
    @credentials = {
      user: ENV["EDS_USER_ID"],
      pass: ENV["EDS_PASSWORD"],
      profile: @profile_id,
      guest: guest
    }
    # puts "==================="
    # puts "EDS: guest? #{guest}"
    # puts "EDS: IP #{ip}"
    # puts "==================="
    @session = EBSCO::EDS::Session.new(@credentials)
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

  def newspapers_count(text)
    if text.empty?
      return 0
    end
    options = {
      query: text,
      results_per_page: 5,
      highlight: false,
      limiters: ["RV:y"]      # peer-reviewed only (yes)
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
