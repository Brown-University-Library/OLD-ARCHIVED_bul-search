require "./app/models/eco_summary.rb"

namespace :josiah do
  desc "Creates the default lists and populates them"
  task "ecosystem_init" => :environment do |_cmd, args|
    puts "Initializing EcoSummary, EcoRanges, and EcoDetails tables..."
    EcoSummary.create_sample_lists()
    puts "Done"
  end
end
