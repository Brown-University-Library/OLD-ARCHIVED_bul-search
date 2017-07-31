require "./lib/http_json.rb"
require "./app/models/eds_results.rb"
require 'ebsco/eds'

class Eds

  def initialize()
    @profile_id = ENV["EDS_PROFILE_ID"]
    @credentials = {
      user: ENV["EDS_USER_ID"],
      pass: ENV["EDS_PASSWORD"],
      profile: @profile_id
    }
    puts @credentials
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
end
