require "./app/models/best_bet_entry.rb"
require "./app/models/best_bet_term.rb"

namespace :josiah do
  desc "Populates BestBets tables with data from a JSON file"
  task "best_bets_init" => :environment do |_cmd, args|
    puts "Initializing BestBets tables..."
    text = File.read("./bestbets.json")
    data = JSON.parse(text)
    BestBetEntry.import(data["rows"])
    puts "Done"
  end
end
