require "./lib/http_json.rb"
require "./app/models/eds.rb"
namespace :eds do
  task "connect" => :environment do |_cmd, _args|
    puts "Connecting to EDS..."
    url = "https://eds-api.ebscohost.com/authservice/rest/UIDAuth"
    credentials = {
      UserId: "**",
      Password: "**",
      InterfaceId: "**"
    }
    resp = HttpUtil::HttpJson.post(url, credentials.to_json)
    puts resp
  end

  task "search", [:text] => :environment do |_cmd, args|
    text = args[:text]
    abort "Must pass text to search" if text == nil
    puts "Searching in EDS for: [#{text}]..."
    eds = Eds.new("TODO", "TODO")
    response = eds.search(text)
    response_to_console(response)
  end

  def response_to_console(response)
    records_to_console(response)
    totals_to_console(response)
    facets_to_console(response)
  end

  def records_to_console(response)
    puts "-"
    puts "Records"
    records = response["SearchResult"]["Data"]["Records"]
    records.each do |r|
      id = r["ResultId"]
      title = item_by_name(r["Items"], "Title")
      isbn = item_by_name(r["Items"], "ISBN")
      author = item_by_name(r["Items"], "Author")
      type = r["Header"]["ResourceType"]
      puts "\t#{id}. #{title} by #{author} (#{type}) #{isbn}"
    end
  end

  def totals_to_console(response)
    total_hits = response["SearchResult"]["Statistics"]["TotalHits"]
    puts "-"
    puts "Total hits: #{total_hits}"
  end

  def facets_to_console(response)
    puts "-"
    puts "Facets"
    facets = response["SearchResult"]["AvailableFacets"]
    facets.each do |f|
      id = f["Id"]
      puts "\t#{id}"
      f["AvailableFacetValues"].each do |v|
        value = v["Value"]
        count = v["Count"]
        puts "\t\t#{value} (#{count})"
      end
    end
  end

  def item_by_name(items, name)
    item = items.select {|e| e["Name"] == name}.first
    return nil if item == nil
    item["Data"]
  end

end
