require "./app/models/libguides.rb"

namespace :josiah do
  desc "Updates Lib Guides cache"
  task "libguides_update_cache" => :environment do |_cmd, args|
    puts "Updating Lib Guides cache..."
    guides = Libguides.new
    errors = guides.cache_update()
    if errors.count == 0
      puts "OK"
    else
      puts "Errors updating Lib Guide:"
      errors.each do |err|
        puts "\t#{err}"
      end
    end
  end
end
