class SearchesStats
  # valid provider values for EDS: "eds" and "newspaper_articles_eds"
  # valid provider values for Summon: "summon", "newspaper_articles"
  def initialize(provider, begin_date, end_date)
    @provider = provider
    @begin_date = begin_date
    @end_date = end_date
    @searches_data = nil
  end

  def searches()
    @searches_data ||= begin
      query = "(created_at between ? and ?) and query_params like ?"
      source = "%source: #{@provider}%"
      Search.where(query, @begin_date, @end_date, source)
    end
  end

  def search_times()
    results = []
    searches().each do |s|
      params = s[:query_params]
      results << {q: params[:q], elapsed_ms: params[:elapsed_ms], id: s[:id]}
    end
    results
  end

  def query_params()
    results = []
    searches().each do |s|
      results << s[:query_params]
    end
    results
  end

  def times()
    values = []
    searches().each do |s|
      params = s[:query_params] || {}
      time = params[:elapsed_ms].to_i
      next if time == 0
      values << time
    end
    values
  end

  def median()
    values = times().sort()
    return 0 if values.length == 0
    if (values.length % 2) == 0
      a = values.length/2
      b = a + 1
      result = (values[a] + values[b]) / 2
    else
      a = (values.length / 2).to_i
      result = values[a]
    end
    result
  end

  def average()
    values = times()
    return 0 if values.length == 0
    values.sum() / values.length
  end
end
