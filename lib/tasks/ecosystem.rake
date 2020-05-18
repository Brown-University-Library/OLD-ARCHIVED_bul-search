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

  desc "Repopulates information for a given collection ID"
  task "ecosystem_refresh", [:id] => :environment do |_cmd, args|
    id = (args[:id] || "").to_i
    puts "Refreshing data for EcoSummary #{id}..."
    summary = EcoSummary.find(id)
    summary.refresh()
    puts "Done"
  end

  desc "Repopulates information for the next pending collection"
  task "ecosystem_catchup" => :environment do |_cmd, args|
    done = EcoSummary.refresh_next()
    if done
      puts "All caught up!"
    else
      puts "Collections are still pending."
    end
  end

  desc "Regenerates the TSV file for a given collection ID"
  task "ecosystem_tsv", [:id] => :environment do |_cmd, args|
    id = (args[:id] || "").to_i
    summary = EcoSummary.find(id)
    filename = summary.filename_tsv()
    puts "Regenerating TSV file #{filename} for EcoSummary #{id}..."
    EcoDetails.to_tsv_file(filename, summary.id)
    puts "Done"
  end
end
