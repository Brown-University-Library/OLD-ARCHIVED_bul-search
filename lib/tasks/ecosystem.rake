require "./app/models/eco_summary.rb"

namespace :josiah do
  desc "Creates the default lists and populates them"
  task "ecosystem_init" => :environment do |_cmd, args|
    puts "Deleting previous data..."
    EcoDetails.delete_all
    EcoRange.delete_all
    EcoSummary.delete_all

    puts "Initializing EcoSummary, EcoRanges, and EcoDetails tables..."
    EcoSummary.create_sample_lists()
    puts "Done"
  end
end
