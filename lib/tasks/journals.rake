require "./app/models/libguides.rb"

namespace :josiah do
  desc "Timing stats for journals"
  task "journal_eds_stats" => :environment do |_cmd, args|
    puts "Fetching stats..."
    st = SearchesStats.new("eds", "2017-08-01", "2017-10-01")
    print(st)
  end

  task "journal_summon_stats" => :environment do |_cmd, args|
    puts "Fetching stats..."
    st = SearchesStats.new("summon", "2017-08-01", "2017-10-01")
    print(st)
  end

  def print(st)
    puts "Median (ms): #{st.median()}"
    puts "Average (ms): #{st.average()}"
    times = st.search_times()
    puts "# searches: #{times.count}"
    times.each do |s|
      elapsed_ms = (s[:elapsed_ms] || "0").to_i
      q = (s[:q] || "").strip
      if q == ""
        q = "--"
      end
      puts "\t#{s[:id]}\t#{elapsed_ms}\t#{q}"
    end
    puts "=="  end
end
