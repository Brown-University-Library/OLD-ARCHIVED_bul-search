class Eds

  def initialize(base_url, credentials)
    @base_url = "https://eds-api.ebscohost.com"
    @profile_id = ENV["EDS_PROFILE_ID"]
    @credentials = {
      UserId: ENV["EDS_USER_ID"],
      Password: ENV["EDS_PASSWORD"],
      InterfaceId: @profile_id
    }
    @auth_token = nil
    @session_token = nil
  end

  def auth_token
    # TODO: make sure the token still is valid (via AuthTimeout in response)
    return @auth_token if @auth_token
    url = @base_url + "/authservice/rest/UIDAuth"
    response = HttpUtil::HttpJson.post(url, @credentials.to_json)
    if response != nil && response["AuthToken"] != nil
      @auth_token = response["AuthToken"]
      @auth_timeout = response["AuthTimeout"]
    end
    @auth_token
  end

  def session_token
    return @session_token if @session_token
    url = @base_url + "/edsapi/rest/CreateSession?profile=#{@profile_id}&guest=n"
    headers = [{key: "x-authenticationToken", value: auth_token()}]
    response = HttpUtil::HttpJson.get(url, headers)
    if response != nil && response["SessionToken"] != nil
      @session_token = response["SessionToken"]
    end
    @session_token
  end

  def search(text)
    url = @base_url + "/edsapi/publication/Search?query=#{text}&resultsperpage=20&pagenumber=1&sort=relevance&highlight=n&includefacets=y&view=brief&autosuggest=n"
    headers = []
    headers << {key: "x-authenticationToken", value: auth_token()}
    headers << {key: "x-sessionToken", value: session_token()}
    response = HttpUtil::HttpJson.get(url, headers)
    response
  end
end
