require "./app/models/libguides.rb"

namespace :josiah do
  desc "Stats for journals (EDS)"
  task "journals_eds_stats", [:begin_date, :end_date] => :environment do |_cmd, args|
    begin_date = default_begin_date(args[:begin_date])
    end_date = default_end_date(args[:end_date])
    st = SearchesStats.new("eds", begin_date, end_date)
    print(st, begin_date, end_date, false)
  end

  desc "Stats for journals (Summon)"
  task "journals_summon_stats", [:begin_date, :end_date] => :environment do |_cmd, args|
    begin_date = default_begin_date(args[:begin_date])
    end_date = default_end_date(args[:end_date])
    st = SearchesStats.new("summon", begin_date, end_date)
    print(st, begin_date, end_date, false)
  end

  desc "Detailed stats for journals (EDS)"
  task "journals_eds_details", [:begin_date, :end_date] => :environment do |_cmd, args|
    begin_date = default_begin_date(args[:begin_date])
    end_date = default_end_date(args[:end_date])
    st = SearchesStats.new("eds", begin_date, end_date)
    print(st, begin_date, end_date, true)
  end

  desc "Detailed stats for journals (Summon)"
  task "journals_summon_details", [:begin_date, :end_date] => :environment do |_cmd, args|
    begin_date = default_begin_date(args[:begin_date])
    end_date = default_end_date(args[:end_date])
    st = SearchesStats.new("summon", begin_date, end_date)
    print(st, begin_date, end_date, true)
  end

  def print(st, begin_date, end_date, show_details)
    times = st.search_times()
    puts "Total searches: #{times.count} (from #{begin_date} to #{end_date})"
    puts "Median (ms): #{st.median()}"
    puts "Average (ms): #{st.average()}"
    if show_details
      puts "\tID\tTime(ms)\tAt\tQuery"
      times.each do |s|
        elapsed_ms = (s[:elapsed_ms] || "0").to_i
        q = (s[:q] || "").strip
        at = (s[:created_at] || "--")
        if q == ""
          q = "--"
        end
        puts "\t#{s[:id]}\t#{elapsed_ms}\t#{at}\t#{q}"
      end
    end
    puts "=="
  end

  def today_utc()
    Time.now.utc.to_date
  end

  def default_begin_date(date)
    if date == nil
      today_utc.to_s + " 00:00:00"
    else
      date
    end
  end

  def default_end_date(date)
    if date == nil
      today_utc.to_s + " 23:59:59"
    else
      date
    end
  end
end
