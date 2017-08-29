require "./app/models/libguides.rb"

namespace :josiah do
  desc "Timing stats for journals"
  task "journal_eds_stats", [:begin_date, :end_date] => :environment do |_cmd, args|
    begin_date = args[:begin_date] || "2017-08-01"
    end_date = args[:end_date] ||"2017-10-01"
    st = SearchesStats.new("eds", begin_date, end_date)
    print(st, begin_date, end_date)
  end

  task "journal_summon_stats" => :environment do |_cmd, args|
    begin_date = "2017-08-01"
    end_date = "2017-10-01"
    st = SearchesStats.new("summon", begin_date, end_date)
    print(st, begin_date, end_date)
  end

  def print(st, begin_date, end_date)
    times = st.search_times()
    puts "Total searches: #{times.count} (from #{begin_date} to #{end_date})"
    puts "Median (ms): #{st.median()}"
    puts "Average (ms): #{st.average()}"
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
