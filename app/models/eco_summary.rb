# status:
#       OK - data is up to date, nothing else to do.
#       UPDATED - data has been updated, needs to be recalculated.
#       CALCULATING - data is being recalculated.
class EcoSummary < ActiveRecord::Base
    def can_view?(user)
        if public == 1
            return true
        end
        created_by == EcoSummary.safe_user_id(user)
    end

    def can_edit?(user)
        if EcoSummary.edit_user?(user)
            return public == 1 || created_by == EcoSummary.safe_user_id(user)
        end
        return false
    end

    def can_delete?(user)
        EcoSummary.edit_user?(user) && created_by == EcoSummary.safe_user_id(user)
    end

    def filename_tsv
        ENV["ECOSYSTEM_DOWNLOADS"] + "/dashboard_#{self.id}.tsv"
    end

    def buildings_excluded
        if self.buildings_allowed == nil
            return []
        end
        Building.all_names - self.buildings_allowed.split("|")
    end

    def owner_id
        id = (created_by || "")
        id.gsub("@", "_").gsub(".", "_")
    end

    def owner_display
        tokens = (created_by || "").split("@")
        if tokens.count == 0
            return "N/A"
        end
        tokens[0].gsub("_", " ")
    end

    def self.can_new?(user)
        EcoSummary.edit_user?(user)
    end

    def self.edit_user?(user)
        if ENV["LOCALHOST"] == "true"
            return true
        end
        return false if user == nil
        user_token = "/#{EcoSummary.safe_user_id(user)}/"
        return (ENV["DASHBOARD_USERS"] || "").include?(user_token)
    end

    def self.editors(user)
        if !self.edit_user?(user)
            # Not sure if we should hide the editors to all other non-editors
            return []
        end
        data = []
        (ENV["DASHBOARD_USERS"] || "").split("/").each do |user_id|
            data << user_id
        end
        data
    end

    def self.new_for_user(user)
        user_name = EcoSummary.safe_user_id(user)
        summary = EcoSummary.new()
        summary.list_name = "#{user_name}'s new list"
        summary.description = ""
        summary.status = "UPDATED"
        summary.created_at = Time.now
        summary.created_by = user_name
        summary.buildings_allowed = self.default_buildings_string()
        summary.public = 1
        summary.save
        summary
    end

    def self.safe_user_id(user)
        if ENV["LOCALHOST"] == "true"
          return "josiah@localhost"
        end
        if user == nil
            return ""
        end
        user.to_s
    end

    # Create a copy of an EcoSummary and its related EcoRanges
    def self.copy(id, user)
        original = EcoSummary.find(id)
        summary = EcoSummary.new()
        summary.list_name = "Copy of #{original.list_name}"
        summary.description = original.description
        summary.status = "UPDATED"
        summary.created_at = Time.now
        summary.created_by = EcoSummary.safe_user_id(user)
        summary.buildings_allowed = original.buildings_allowed
        summary.public = 1
        summary.save!

        original.ranges.each do |range|
            r = EcoRange.new
            r.eco_summary_id = summary.id
            r.from = range.from
            r.to = range.to
            r.name = range.name
            r.save!
        end

        summary
    end

    # Update an EcoSummary with the data tha comes in a web request
    def save_from_request(params, user)
        self.list_name = params["name"]
        self.description = params["description"]
        self.status = "UPDATED"
        self.updated_at = Time.now
        self.updated_by = EcoSummary.safe_user_id(user)
        self.public = 1 # (params["public"] == "yes") ? 1 : 0
        save

        ranges = params.keys.select {|k| k.start_with?("cn_range_") && k.end_with?("_from")}
        ranges.each do |key|
            range_id = key.gsub("cn_range_", "").gsub("_from", "").to_i
            r = EcoRange.find(range_id)

            cn_from = (params[key] || "").strip
            cn_to = (params[key.gsub("_from", "_to")] || "").strip
            cn_name = (params[key.gsub("_from", "_name")] || "").strip

            # Empty range, delete it.
            if cn_from == "" && cn_to == ""
                r.delete
                next
            end

            r.from = safe_range_from_value(cn_from, cn_to)
            r.to = safe_range_to_value(cn_from, cn_to)
            r.name = cn_name
            r.save
        end

        new_ranges = params.keys.select {|k| k.start_with?("cn_new_") && k.end_with?("_from")}
        new_ranges.each do |key|
            cn_from = (params[key] || "").strip
            cn_to = (params[key.gsub("_from", "_to")] || "").strip
            cn_name = (params[key.gsub("_from", "_name")] || "").strip

            # Empty range, don't save it.
            if cn_from == "" && cn_to == ""
                next
            end

            r = EcoRange.new
            r.eco_summary_id = self.id
            r.from = safe_range_from_value(cn_from, cn_to)
            r.to = safe_range_to_value(cn_from, cn_to)
            r.name = cn_name
            r.save
        end
    end

    def status_message
        case
            when self.status == "OK"
                return "OK"
            when self.status == "UPDATED"
                return "Queued"
            when self.status == "CALCULATING"
                return "Recalculating"
        end
        return "Unknown"
    end

    def status_tooltip
        case
            when self.status == "OK"
                return "Collection data is up to date"
            when self.status == "UPDATED"
                return "Collection is queued to be recalculated, data is currently stale."
            when self.status == "CALCULATING"
                return "Data is being recalculated for this collection."
        end
        return "Unknown"
    end

    def status_icon
        case
            when self.status == "OK"
                return "glyphicon glyphicon-ok"
            when self.status == "UPDATED"
                return "glyphicon glyphicon-hourglass"
            when self.status == "CALCULATING"
                return "glyphicon glyphicon-cog"
        end
        return "Unknown"
    end

    def list_full_name
        if sierra_list == nil
            return list_name
        end
        "#{list_name} (Sierra List #{sierra_list})"
    end

    def languages()
        @languages ||= EcoLanguages.where(eco_summary_id: id).sort_by {|x| x.total }.reverse
    end

    def languages_top_10()
        misc_print = 0
        misc_online = 0
        misc_total = 0
        misc_count = 0
        top10 = []
        languages().each_with_index do |row, ix|
            if ix <= 8
                data = OpenStruct.new(
                    name: row.name,
                    print: row.print,
                    online: row.online,
                    total: row.total,
                    percent: (total_bibs == 0) ? 0 : ((row.total * 100) / total_bibs)
                )
                top10 << data
            else
                misc_count += 1
                misc_print += row.print
                misc_online += row.print
                misc_total += row.total
            end
        end
        if misc_count > 0
            misc = OpenStruct.new(
                name: "All others (#{misc_count})",
                print: misc_print,
                online: misc_online,
                total: misc_total,
                percent: (total_bibs == 0) ? 0 : ((misc_total * 100) / total_bibs)
            )
            top10 << misc
        end
        top10
    end

    def ranges()
        EcoRange.where(eco_summary_id: id)
    end

    def total_bibs()
        self.bib_count || 0
    end

    def total_bibs_2015_plus()
        total = 0
        acquisitions_bib().each do |row|
            if row.year >= 2015
                total += row.total
            end
        end
        total
    end

    def total_items()
        self.item_count || 0
    end

    def locations()
        Rails.cache.fetch("ecosystem_#{self.id}_locations", expires_in: 25.minute) do
            begin
                sql = <<-END_SQL.gsub(/\n/, '')
                    select location_code as location_code, count(*) as count
                    from eco_details
                    where eco_summary_id = #{id}
                    group by location_code
                    order by 2 desc, 1 asc
                END_SQL
                rows = ActiveRecord::Base.connection.exec_query(sql).rows
                data = rows.map do |r|
                    percent = (total_items == 0) ? 0 : ((r[1] * 100) / total_items)
                    name = Location.get_name(r[0])
                    OpenStruct.new(name: name, code: r[0], count: r[1], percent: percent)
                end
                data
            rescue Exception => e
                Rails.logger.error "Error in locations() for #{self.id}: #{e.to_s}"
                []
            end
        end
    end

    def buildings()
        # Summarize the location codes into buildings
        counts = {}
        locations().each do |loc|
            name = Building.name(loc.code)
            if name == nil
                name = "Unknown"
            end
            if counts[name] == nil
                counts[name] = 0
            end
            counts[name] += loc.count
        end

        # Calculate the percents
        buildings = []
        counts.keys.each do |key|
            count = counts[key]
            percent = (total_items == 0) ? 0 : ((count * 100) / total_items)
            buildings << OpenStruct.new(name: key, code: key, count: count, percent: percent)
        end

        buildings.sort_by {|x| x.count }.reverse
    end

    def checkouts()
        Rails.cache.fetch("ecosystem_#{self.id}_checkouts", expires_in: 25.minute) do
            begin
                sql = <<-END_SQL.gsub(/\n/, '')
                    select checkout_total as checkout_total, count(*) as count
                    from eco_details
                    where eco_summary_id = #{id}
                    group by checkout_total
                    order by 2 desc, 1 asc
                END_SQL
                rows = ActiveRecord::Base.connection.exec_query(sql).rows
                data = rows.map do |r|
                    percent = (total_items == 0) ? 0 : ((r[1] * 100) / total_items)
                    OpenStruct.new(code: r[0].to_s, count: r[1], percent: percent)
                end
                data
            rescue Exception => e
                Rails.logger.error "Error in checkouts() for #{self.id}: #{e.to_s}"
                []
            end
        end
    end

    def checkouts_2015()
        Rails.cache.fetch("ecosystem_#{self.id}_checkouts_2015", expires_in: 25.minute) do
            begin
                sql = <<-END_SQL.gsub(/\n/, '')
                    select checkout_2015_plus as checkout_total, count(*) as count
                    from eco_details
                    where eco_summary_id = #{id}
                    group by checkout_2015_plus
                    order by 2 desc, 1 asc
                END_SQL
                rows = ActiveRecord::Base.connection.exec_query(sql).rows
                data = rows.map do |r|
                    percent = (total_items == 0) ? 0 : ((r[1] * 100) / total_items)
                    OpenStruct.new(code: r[0].to_s, count: r[1], percent: percent)
                end
                data
            rescue Exception => e
                Rails.logger.error "Error in checkouts_2015() for #{self.id}: #{e.to_s}"
                []
            end
        end
    end

    def usage_subject_2015()
        Rails.cache.fetch("ecosystem_#{self.id}_usage_subject_details", expires_in: 25.minute) do
            EcoSubjects.acquired_vs_checkedout_2015(id, true)
        end
    end

    def checkouts_2015_details()
        Rails.cache.fetch("ecosystem_#{self.id}_checkouts_details", expires_in: 25.minute) do
            begin
                sql = <<-END_SQL.gsub(/\n/, '')
                    select year(bib_create_date),
                        count(distinct id) as count_all,
                        sum(case when is_online = 1 then 1 else 0 end) as count_online,
                        sum(case when is_online = 1 then 0 else 1 end) as count_physical,
                        sum(case when checkout_2015_plus >= 1 then 1 else 0 end) as ck1_count,
                        sum(case when checkout_2015_plus >= 2 then 1 else 0 end) as ck2_count,
                        sum(case when checkout_2015_plus >= 3 then 1 else 0 end) as ck3_count,
                        sum(case when checkout_2015_plus >= 5 then 1 else 0 end) as ck5_count
                    from eco_details
                    where eco_summary_id = #{id} and year(bib_create_date) >= 2015
                    group by year(bib_create_date)
                    order by 1 desc;
                END_SQL
                rows = ActiveRecord::Base.connection.exec_query(sql).rows
                data = rows.map do |r|
                    count_all = r[1]
                    count_online = r[2]
                    count_physical = r[3]
                    percent_online = (count_all == 0) ? 0 : ((count_online * 100) / count_all)
                    percent_physical = (count_all == 0) ? 0 : ((count_physical * 100) / count_all)
                    OpenStruct.new(
                        year: r[0],
                        count_all: count_all,
                        count_online: count_online,
                        percent_online: percent_online,
                        count_physical: count_physical,
                        percent_physical: percent_physical,
                        ck1_count: r[4],
                        ck2_count: r[5],
                        ck3_count: r[6]
                    )
                end

                data
            rescue Exception => e
                Rails.logger.error "Error in checkouts_2015_details() for #{self.id}: #{e.to_s}"
                []
            end
        end
    end

    def acquisitions_bib()
        EcoAcquisitions.where(eco_summary_id: self.id, acq_type: "bib").order(year: :desc)
    end

    def acquisitions_bib()
        EcoAcquisitions.where(eco_summary_id: self.id, acq_type: "bib").order(year: :desc)
    end

    def format_acquisitions_bib()
        data = []
        acquisitions_bib().each do |row|
            if row.year >= 2015
                percent_online = 0
                if row.total > 0
                    percent_online = (row.online * 100) / row.total
                end
                data << OpenStruct.new(year: row.year, total: row.total, online: row.online, online_percent: percent_online)
            end
        end
        data
    end

    def acquisitions_item()
        Rails.cache.fetch("ecosystem_#{self.id}_acquisitions_item", expires_in: 25.minute) do
            begin
                sql = <<-END_SQL.gsub(/\n/, '')
                    select year(item_create_date) as year, count(distinct item_record_num) as count
                    from eco_details
                    where eco_summary_id = #{id}
                    group by year(item_create_date)
                    order by 2 desc, 1 asc
                END_SQL
                rows = ActiveRecord::Base.connection.exec_query(sql).rows
                data = rows.map do |r|
                    percent = (total_items == 0) ? 0 : ((r[1] * 100) / total_items)
                    OpenStruct.new(year: r[0].to_s, count: r[1], percent: percent)
                end
                data
            rescue Exception => e
                Rails.logger.error "Error in acquisitions_item() for #{self.id}: #{e.to_s}"
                []
            end
        end
    end

    def format_access_points()
        Rails.cache.fetch("ecosystem_#{self.id}_access_points", expires_in: 25.minute) do
            begin
                # Notice that we get different counts if we use
                # `distinct id` or `distinct item_record_num`
                sql = <<-END_SQL.gsub(/\n/, '')
                    select format, is_online, count(distinct bib_record_num) as count
                    from eco_details
                    where eco_summary_id = #{id} and format in("Book", "Periodical Title")
                    group by format, is_online
                END_SQL
                rows = ActiveRecord::Base.connection.exec_query(sql).rows

                # Calculate the total count (instead of using bib_count) because
                # we are only interested in Books and Periodicals
                total = rows.reduce(0) {|sum, row| sum + (row[2] || 0)}

                # Populate our data object with the data that we got from the DB.
                data = {
                    book_print_count: 0,
                    book_print_percent: 0,
                    book_online_count: 0,
                    book_online_percent: 0,
                    journal_print_count: 0,
                    journal_print_percent: 0,
                    journal_online_count: 0,
                    journal_online_percent: 0
                }

                rows.each do |r|
                    format = r[0]
                    online = r[1] == 1
                    count = r[2]
                    case
                    when format == "Book" && !online
                        data[:book_print_count] = count
                    when format == "Book" && online
                        data[:book_online_count] = count
                    when format == "Periodical Title" && !online
                        data[:journal_print_count] = count
                    when format == "Periodical Title" && online
                        data[:journal_online_count] = count
                    end
                end

                book_total = data[:book_online_count] + data[:book_print_count]
                if book_total > 0
                    data[:book_print_percent] = (data[:book_print_count] * 100) / book_total
                    data[:book_online_percent] = (data[:book_online_count] * 100) / book_total
                end

                journal_total = data[:journal_online_count] + data[:journal_print_count]
                if journal_total > 0
                    data[:journal_print_percent] = (data[:journal_print_count] * 100)/ journal_total
                    data[:journal_online_percent] = (data[:journal_online_count] * 100)/ journal_total
                end

                data
            rescue Exception => e
                Rails.logger.error "Error in acquisitions_item() for #{self.id}: #{e.to_s}"
                nil
            end
        end
    end

    # Refresh the next EcoSummary that is with status = "UPDATED"
    # Makes sure there is only one calculation going on at the same time.
    def self.refresh_next()
        summary = EcoSummary.where(status: "CALCULATING").first
        if summary != nil
            Rails.logger.info("EcoSummary.refresh_next - already calculating #{summary.id}")
            return false
        end

        summary = EcoSummary.where(status: "UPDATED").order(updated_at: :asc).first
        if summary != nil
            Rails.logger.info("EcoSummary.refresh_next - starting #{summary.id}")
            summary.refresh()
            return false
        end

        # Nothing left to process
        Rails.logger.info("EcoSummary.refresh_next - nothing is pending")
        return true
    end

    # Reloads the EcoDetails for the current EcoSummary by refreshing
    # the data of each of the ranges for the summary.
    def refresh()
        Rails.logger.info("EcoSummary.refresh for #{self.id} started")
        self.status = "CALCULATING"
        self.refreshed_at = Time.now
        save!

        # Refresh each of the ranges...
        @lang_counts = {}
        ranges().each do |range|
            Rails.logger.info("EcoSummary.refresh for #{self.id} - processing range #{range.id}")
            refresh_range(range.id)
        end

        # Delete orphan details
        # (from ranges that might not exist anymore)
        Rails.logger.info("EcoSummary.refresh for #{self.id} - deleting orphans")
        sql = <<-END_SQL.gsub(/\n/, '')
          DELETE eco_details
          FROM eco_details
            LEFT OUTER JOIN eco_ranges ON eco_details.eco_range_id = eco_ranges.id
          WHERE eco_details.eco_summary_id = #{id} AND eco_ranges.id IS NULL;
        END_SQL
        orphan_count = ActiveRecord::Base.connection.exec_delete(sql, nil, [])
        if orphan_count > 0
          Rails.logger.info("EcoSummary.refresh for #{self.id} - deleted #{orphan_count} orphans")
        end

        # Refresh children tables...
        refresh_languages()
        refresh_acquisitions()
        refresh_counts()

        Rails.logger.info("EcoSummary.refresh for #{self.id} completed")
    end

    def refresh_acquisitions()
        Rails.logger.info("EcoSummary.refresh for #{self.id} - calculating acquisitions")

        # Delete previous data
        sql = <<-END_SQL
            DELETE FROM eco_acquisitions
            WHERE eco_summary_id = #{self.id};
        END_SQL
        ActiveRecord::Base.connection.exec_delete(sql, nil, [])

        # Calculate new breakdown by year/format
        # https://www.tarynpivots.com/post/how-to-rotate-rows-into-columns-in-mysql/
        sql = <<-END_SQL
            SELECT
                year(bib_create_date) as year,                                                  # 0
                count(id) as total,                                                             # 1
                sum(case when is_online = 1 then 1 else 0 end) as online,                       # 2
                sum(case when format = "Book" then 1 else 0 end) as book,                       # 3
                sum(case when format = "Periodical Title" then 1 else 0 end) as periodical,     # 4
                sum(case when format = "Sound Recording" then 1 else 0 end) as sound,           # 5
                sum(case when format = "Video" then 1 else 0 end) as video,                     # 6
                sum(case when format = "Musical Score" then 1 else 0 end) as score,             # 7
                sum(case when format = "Thesis/Dissertation" then 1 else 0 end) as etd,         # 8
                sum(case when format = "Map" then 1 else 0 end) as map,                         # 9
                sum(case when format = "Computer File " then 1 else 0 end) as file,             # 10
                sum(case when format = "Visual Material" then 1 else 0 end) as visual,          # 11
                sum(case when format = "Archives/Manuscripts" then 1 else 0 end) as archive,    # 12
                sum(case when format = "3D object" then 1 else 0 end) as object,                # 13
                sum(case when format = "Mixed Material" then 1 else 0 end) as mixed             # 14
            FROM eco_details
            WHERE eco_summary_id = #{self.id}
            GROUP BY year(bib_create_date)
            ORDER BY 1 DESC;
        END_SQL
        rows = ActiveRecord::Base.connection.exec_query(sql).rows

        # Save the breakdown
        rows.each do |r|
            acq = EcoAcquisitions.new
            acq.eco_summary_id = self.id
            acq.acq_type = "bib"
            acq.year = r[0]
            acq.total = r[1]
            acq.online = r[2]
            acq.book = r[3]
            acq.periodical = r[4]
            acq.sound = r[5]
            acq.video = r[6]
            acq.score = r[7]
            acq.etd = r[8]
            acq.map = r[9]
            acq.file = r[10]
            acq.visual = r[11]
            acq.archive = r[12]
            acq.object = r[13]
            acq.mixed = r[14]
            acq.unknown = acq.total - (acq.book + acq.periodical + acq.sound +
                acq.video + acq.score + acq.etd + acq.map + acq.file +
                acq.visual + acq.archive + acq.object + acq.mixed)
            acq.save
        end
    end

    # Updates the counts in the EcoSummary by aggregating the totals from the EcoRanges
    def refresh_counts()
        Rails.logger.info("EcoSummary.refresh for #{self.id} - calculating counts")

        bibs_count = 0
        items_count = 0
        ranges().each do |range|
            bibs_count += range.bib_count
            items_count += range.item_count
        end

        self.bib_count = bibs_count
        self.item_count = items_count
        self.status = "OK"
        self.refreshed_at = Time.now
        save!

        EcoDetails.to_tsv_file(filename_tsv(), self.id)

        Rails.cache.delete("ecosystem_#{self.id}_locations")
        Rails.cache.delete("ecosystem_#{self.id}_checkouts")
        Rails.cache.delete("ecosystem_#{self.id}_checkouts_2015")
        Rails.cache.delete("ecosystem_#{self.id}_acquisitions_bib")
        Rails.cache.delete("ecosystem_#{self.id}_acquisitions_item")
    end

    def refresh_languages()
        Rails.logger.info("EcoSummary.refresh for #{self.id} - updating language counts")
        EcoLanguages.delete_all(eco_summary_id: self.id)

        @lang_counts.keys.each do |key|
            lang = EcoLanguages.new
            lang.eco_summary_id = self.id
            data = @lang_counts[key]
            lang.name = key
            lang.online = data[:online]
            lang.print = data[:print]
            lang.total = data[:online] + data[:print]
            lang.save!
        end
    end

    # Recalculate the EcoDetails for a given EcoRange
    def refresh_range(range_id)
        # Delete previous detail records for this range
        EcoDetails.delete_all(eco_summary_id: id, eco_range_id: range_id)

        range = ranges().find {|r| r.id == range_id}
        if range == nil
            # Range has been deleted, nothing to do.
        else
            buildings_filter = (self.buildings_allowed || "").split("|")
            buildings_filter << "Unknown"
            # Fetch items for the call number range and save them in the details table.
            items_count = 0
            bibs_count = 0
            is_range, range_from, range_to = CallnumberNormalizer.normalize_range(range.from, range.to)
            if is_range
                Callnumber.process_by_range(range.from, range.to) do |docs|
                    begin
                        EcoDetails.transaction do
                            docs.each do |doc|
                                items_count += EcoDetails.new_from_solr_doc(id, range.id, doc, range_from, range_to, buildings_filter)
                                # Update our language counts
                                EcoDetails.langs_from_solr_doc(doc).each do |lang|
                                    add_lang_count(lang)
                                end
                            end
                            bibs_count += docs.count
                        end
                    rescue => ex
                        Rails.logger.error("refresh_range: Error processing range (#{range.from}, #{range.to}). Exception #{ex.to_s}")
                    end
                end
            else
                Rails.logger.warn("refresh_range: Not a valid range (#{range.from}, #{range.to}). Range ID: #{range_id}")
            end
            range.item_count = items_count
            range.bib_count = bibs_count
            range.save!
        end
    end

    def self.create_sample_lists()
        # Tiny test list
        ranges = []
        ranges << {from: "B 5180", to: "B 5224", name: "Philosophy (General) / East Asia"}
        ranges << {from: "GV 712", to: "GV 715", name: "Something something"}
        self.create_sample_list("Tiny test list", ranges)

        # Econ Pilot
        ranges = []
        ranges << {from: "HB", to: "HB", name: ""}
        ranges << {from: "HC", to: "HC", name: ""}
        ranges << {from: "HD", to: "HD", name: ""}
        ranges << {from: "HE", to: "HE", name: ""}
        ranges << {from: "HF", to: "HF", name: ""}
        ranges << {from: "HG", to: "HG", name: ""}
        ranges << {from: "HJ", to: "HJ", name: ""}
        ranges << {from: "LC 65", to: "LC 70", name: ""}
        ranges << {from: "QA 269", to: "QA 272", name: ""}
        ranges << {from: "S 560", to: "S 582", name: ""}
        ranges << {from: "T 56.8", to: "T 58.3", name: ""}
        ranges << {from: "GV 712", to: "GV 715", name: ""}
        ranges << {from: "GV 716", to: "GV 716", name: ""}
        ranges << {from: "SB 107", to: "SB 112", name: ""}
        self.create_sample_list("ECON Pilot", ranges)

        # GOBI EA_review
        ranges = []
        ranges << {from: "B 125", to: "B 162", name: "Philosophy (General) / Orient"}
        ranges << {from: "B 5180", to: "B 5224", name: "Philosophy (General) / East Asia"}
        ranges << {from: "B 5230", to: "B 5234", name: "Philosophy (General) / korea"}
        ranges << {from: "B 5240", to: "B 5244", name: "Philosophy (General) / Japan"}
        ranges << {from: "B 5250", to: "B 5254", name: "Philosophy (General) / Korea"}
        ranges << {from: "BF 1779", to: "BF 1779", name: "Psychology / Feng shui"}
        ranges << {from: "BL 1000", to: "BL 2370", name: "Religion / Asian.  Oriental"}
        ranges << {from: "BL 1830", to: "BL 1945", name: "Religion / Confucianism-Taoism"}
        ranges << {from: "BL 2216", to: "BL 2229", name: "Religion / Shinto"}
        ranges << {from: "BR 731", to: "BR 1599", name: "Christianity / History by region or country"}
        ranges << {from: "CD 5001", to: "CD 6471", name: "Diplomatics.  Archives.  Seals / Seals"}
        ranges << {from: "CE 1", to: "CE 97", name: "Technical Chronology.  Calendar / Technical Chronology.  Calendar"}
        ranges << {from: "CJ 1", to: "CJ 6661", name: "Numismatics / Numismatics"}
        ranges << {from: "CN 900", to: "CN 1355", name: "Inscriptions.  Epigraphy / By region or country"}
        ranges << {from: "CS 2300", to: "CS 3090", name: "Genealogy / Personal and family names"}
        ranges << {from: "CT 759", to: "CT 3199", name: "Biography / National biography"}
        ranges << {from: "DS 501", to: "DS 519", name: "Asia / Eastern Asia.  Far East."}
        ranges << {from: "DS 701", to: "DS 800", name: "Asia / China"}
        ranges << {from: "DS 801", to: "DS 900", name: "Asia / Japan"}
        ranges << {from: "DS 901", to: "DS 937", name: "Asia / Korea"}
        ranges << {from: "GB 170.3", to: "GB 399", name: "Physical Geography / By region or country"}
        ranges << {from: "GF 651", to: "GF 700", name: "Human Ecology.  Anthropogeography / Asia"}
        ranges << {from: "GN 590", to: "GN 642", name: "Anthropology / Asian ethnic groups"}
        ranges << {from: "GR 265", to: "GR 349", name: "Folklore / Folklore of Asia"}
        ranges << {from: "GT 1370", to: "GT 1579", name: "Manners and Customs (General) / Clothing of Asia"}
        ranges << {from: "HB 125", to: "HB 126", name: "Economic Theory. Demography / Asia"}
        ranges << {from: "HC 411", to: "HC 470", name: "Economic History and Conditions / Asia"}
        ranges << {from: "J 500", to: "J 703", name: "General Legislative and Executive Papers / Asia"}
        ranges << {from: "JQ 670", to: "JQ 679", name: "Political Institutions and Public Administration: Asia. Africa.  Australia / Hong Kong"}
        ranges << {from: "JQ 1050", to: "JQ 1061", name: "Political Institutions and Public Administration: Asia. Africa.  Australia / Goa.  Macau"}
        ranges << {from: "JQ 1500", to: "JQ 1519", name: "Political Institutions and Public Administration: Asia. Africa.  Australia / China"}
        ranges << {from: "JQ 1520", to: "JQ 1539", name: "Political Institutions and Public Administration: Asia. Africa.  Australia / Taiwan"}
        ranges << {from: "JQ 1600", to: "JQ 1699", name: "Political Institutions and Public Administration: Asia. Africa.  Australia / Japan"}
        ranges << {from: "JQ 1720", to: "JQ 1729", name: "Political Institutions and Public Administration: Asia. Africa.  Australia / Korea"}
        ranges << {from: "KNN 0", to: "KNN 9999", name: "South Asia.  Southeast Asia.  East Asia / China (to 1949)"}
        ranges << {from: "KNP 0", to: "KNP 499", name: "South Asia.  Southeast Asia.  East Asia / Taiwan"}
        ranges << {from: "KNQ 0", to: "KNQ 9999", name: "South Asia.  Southeast Asia.  East Asia / China (People's Republic)"}
        ranges << {from: "KNX 0", to: "KNX 4999", name: "South Asia.  Southeast Asia.  East Asia / Japan"}
        ranges << {from: "KNY 10", to: "KNY 220", name: "South Asia.  Southeast Asia.  East Asia / Japan (Cities, communities, etc.)"}
        ranges << {from: "KPA 0", to: "KPA 4999", name: "South Asia.  Southeast Asia.  East Asia / South Korea"}
        ranges << {from: "KPC 0", to: "KPC 4999", name: "South Asia.  Southeast Asia.  East Asia / North Korea"}
        ranges << {from: "LA 1050", to: "LA 1429", name: "History of Education / Asia"}
        ranges << {from: "LG 1", to: "LG 400", name: "Education - Individual Institutions / Asia"}
        ranges << {from: "ML 330", to: "ML 345", name: "Literature on Music / Asia"}
        ranges << {from: "PL 1", to: "PL 8844", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Languages and Literatures of Eastern Asia, Africa, Oceania"}
        ranges << {from: "PL 491", to: "PL 5000", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Far Eastern languages and literatures"}
        ranges << {from: "PL 501", to: "PL 898", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Japanese"}
        ranges << {from: "PL 501", to: "PL 699", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Language"}
        ranges << {from: "PL 701", to: "PL 898", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Literature"}
        ranges << {from: "PL 901", to: "PL 998", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Korean"}
        ranges << {from: "PL 901", to: "PL 949", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Language"}
        ranges << {from: "PL 950", to: "PL 998", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Literature"}
        ranges << {from: "PL 1001", to: "PL 3279", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Chinese"}
        ranges << {from: "PL 1001", to: "PL 2239", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Language"}
        ranges << {from: "PL 2250", to: "PL 3300", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Literature"}
        ranges << {from: "PL 3301", to: "PL 5000", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Other groups"}
        ranges << {from: "PN 1995.9.K35", to: "PN 1995.9.K35", name: "Literature: General and Universal Literary History / Kanagawa-ken (Japan)"}
        ranges << {from: "PN 1995.9.K95", to: "PN 1995.9.K95", name: "Literature: General and Universal Literary History / Kyushu Region (Japan)"}
        ranges << {from: "Z 787", to: "Z 1000", name: "Bibliography.  Library Science / Libraries"}
        ranges << {from: "Z 1946", to: "Z 6953.7", name: "Bibliography.  Library Science / Bibliography.  Books and reading"}
        self.create_sample_list("GOBI--2020_01_LC Subject Grouping_EA_review", ranges)
    end

    def self.create_sample_list(name, ranges)
        s = EcoSummary.new
        s.list_name = name
        s.status = "UPDATED"
        s.created_at = Time.now
        s.created_by = 'hector_correa@brown.edu'
        s.buildings_allowed = self.default_buildings_string()
        s.public = 1
        s.save!

        ranges.each do |range|
            r = EcoRange.new
            r.eco_summary_id = s.id
            r.from = range[:from]
            r.to = range[:to]
            r.name = range[:name]
            r.save!
        end

        # Notice that we don't populate them right away since it
        # takes a long time. Instead we let the cronjob populate
        # them on schedule.
    end

    def self.default_buildings()
        Building.all_names - ["John Carter Brown", "Hay"]
    end

    def self.default_buildings_string()
        default_buildings().join("|")
    end

    private
        # Adds or updates the data to the @lang_counts instance variable:
        #
        #   @lang_counts = {
        #       "english": {print: 10, online: 3},
        #       "spanish": {print: 3, online: 0}
        #   }
        #
        # The data argument is a hash with the print and online counts for a given
        # language, for example:
        #
        #   data = {"english": {print: 2, online: 0}}
        #
        def add_lang_count(data)
            code = data.keys.first
            if @lang_counts[code] == nil
                # First time we see this language
                @lang_counts[code] = {
                    print: data[code][:print],
                    online: data[code][:online]
                }
            else
                # Update the counts for this language
                @lang_counts[code] = {
                    print: @lang_counts[code][:print] + data[code][:print],
                    online: @lang_counts[code][:online] + data[code][:online]
                }
            end
        end

        # Given a pair of from/to values returns a "safe" value
        # to use as a "from" value. At least one of the values
        # must not be empty.
        def safe_range_from_value(cn_from, cn_to)
            if cn_from == "" && cn_to != ""
                # We only have a "to" value, use that.
                return cn_to
            end
            cn_from
        end

        # Given a pair of from/to values returns a "safe" value
        # to use as a "to" value. At least one of the values
        # must not be empty.
        def safe_range_to_value(cn_from, cn_to)
            if cn_from != "" && cn_to == ""
                # We only have a "from" value, use that.
                return cn_from
            end
            cn_to
        end
end