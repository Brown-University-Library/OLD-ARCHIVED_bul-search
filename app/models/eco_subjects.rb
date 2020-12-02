class EcoSubjects
    # Get subjects sorted by number of acquisitions since 2015
    # (physical records only)
    def self.acquired_2015(summary_id)
        subjects_counts = {}
        sql = <<-END_SQL.gsub(/\n/, '')
            select subjects
            from eco_details
            where eco_summary_id = #{summary_id} and
                year(bib_create_date) >= 2015 and
                is_online = 0;
        END_SQL

        rows = ActiveRecord::Base.connection.exec_query(sql).rows
        rows.each do |row|
            subjects = (row[0] || "(NONE)").split("|")
            subjects.each do |subject|
                if subjects_counts[subject] == nil
                    subjects_counts[subject] = 1
                else
                    subjects_counts[subject] = subjects_counts[subject] + 1
                end
            end
        end

        return subjects_counts

        sorted = subjects_counts.map do |x|
            {
                key: x[0],
                value: x[1]
            }
        end.sort_by { |y| y[:value] }.reverse

        return sorted
    end

    # Returns subjects sorted by number of checkouts since 2015
    # (physical records only)
    def self.checkedout_2015(summary_id)
        subjects_counts = {}
        sql = <<-END_SQL.gsub(/\n/, '')
            select subjects
            from eco_details
            where eco_summary_id = #{summary_id} and
                year(bib_create_date) >= 2015 and
                is_online = 0 and
                checkout_2015_plus >= 1;
        END_SQL

        rows = ActiveRecord::Base.connection.exec_query(sql).rows
        rows.each do |row|
            subjects = (row[0] || "(NONE)").split("|")
            subjects.each do |subject|
                if subjects_counts[subject] == nil
                    subjects_counts[subject] = 1
                else
                    subjects_counts[subject] = subjects_counts[subject] + 1
                end
            end
        end

        return subjects_counts

        sorted = subjects_counts.map do |x|
            {
                key: x[0],
                value: x[1]
            }
        end.sort_by { |y| y[:value] }.reverse

        return sorted
    end

    def self.acquired_vs_checkedout_2015(summary_id, top10 = false)
        # Get subjects acquired and subjects checked out and their respective counts
        acquired = self.acquired_2015(summary_id)
        checkedout = self.checkedout_2015(summary_id)

        # Merge both lists into a single one. Note that I am using a hash so that
        # we can access individual items by key (subject is the key)
        merged = {}
        acquired.each do |x|
            key = x[0]
            value = x[1]
            merged[key] = {acq: value, ck: 0}
        end

        checkedout.each do |x|
            key = x[0]
            value = x[1]
            if merged[key]
                merged[key] = {acq: merged[key][:acq], ck: value}
            else
                merged[key] = {acq: 0, ck: value}
            end
        end

        # Get keys sorted by number of acquisitions and number of check outs
        acq = merged.keys.sort_by {|k| -merged[k][:acq]}
        ck = merged.keys.sort_by {|k| -merged[k][:ck]}

        if top10
            acq = acq.take(10)
            ck = ck.take(10)
        end

        # Build an array with the combined data.
        # We use the sorted keys (acq and ck) to pluck the data in order from the
        # merged list. The merged list will be sorted descending by acquisition
        # and then by check out counts.
        data = []
        acq.each do |key|
            value = merged[key]
            row = OpenStruct.new(subject: key, acq_count: value[:acq], checkout_count: value[:ck])
            data << row
        end

        ck.each do |key|
            if !acq.include?(key)
                value = merged[key]
                row = OpenStruct.new(subject: key, acq_count: value[:acq], checkout_count: value[:ck])
                data << row
            end
        end

        return data
    end
end