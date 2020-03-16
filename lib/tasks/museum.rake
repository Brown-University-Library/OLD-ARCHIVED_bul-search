require "./app/models/haffenreffer.rb"

namespace :josiah do
  desc "Gets artifacts from the Haffenreffer MuseumPlus website"
  task "haffenreffer_fetch_raw" => :environment do |_cmd, args|
    h = Haffenreffer.new()
    xml = h.get_source_items_raw()
    puts xml
  end

  desc "Gets artifacts from the Haffenreffer MuseumPlus website"
  task "haffenreffer_fetch" => :environment do |_cmd, args|
    h = Haffenreffer.new()
    puts h.get_source_items()
  end

  desc "Imports Haffenreffer's artifacts into Solr"
  task "haffenreffer_import" => :environment do |_cmd, args|
    puts "Importing artifacts from the Haffenreffer..."
    h = Haffenreffer.new()
    items = h.get_source_items()
    h.update_solr(items)
    puts "Done."
  end
end
