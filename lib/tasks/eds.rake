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
    results = eds.search(text)
    results_to_console(results)
  end

  def results_to_console(results)
    puts "-"
    puts "Records"
    results.items.each do |i|
      puts "\t#{i[:id]}. #{i[:title]}, #{i[:author]} (#{i[:type]}) #{i[:isbn]}"
    end

    puts "-"
    puts "Total hits: #{results.total_hits}"

    puts "-"
    puts "Facets"
    results.facets.each do |f|
      puts "\t#{f[:id]}"
      f[:data].each do |d|
        puts "\t\t#{d[:value]} (#{d[:count]})"
      end
    end
  end
end
