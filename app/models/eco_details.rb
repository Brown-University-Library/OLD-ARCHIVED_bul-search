class EcoDetails < ActiveRecord::Base

    def josiah_bib_id
        "b#{bib_record_num}"
    end

    def self.summary(subject)
        if subject != "ECON"
            return nil
        end

        Rails.cache.fetch("dashboard_summary_#{subject}", expires_in: 1.day) do
            sierra_list = 334
            counts = summary_counts(sierra_list)
            data = {
                name: subject,
                sierra_list: sierra_list,
                bib_count: counts[:bib_count],
                item_count: counts[:item_count],
                locations: summary_location(sierra_list),
                callnumbers: summary_callnumber(sierra_list),
                checkouts: summary_checkout(sierra_list),
                fund_codes: summary_fund_codes(sierra_list),
                subjects: summary_subjects(sierra_list)
            }
        end
    end

    def self.summary_counts(sierra_list)
        sql = <<-END_SQL.gsub(/\n/, '')
            SELECT count(distinct bib_record_num), count(distinct item_record_num)
            FROM eco_details
            WHERE sierra_list = #{sierra_list};
        END_SQL
        rows = ActiveRecord::Base.connection.exec_query(sql).rows
        if rows == nil || rows.count != 1
            return {bib_count: 0, item_count: 0}
        end
        return {bib_count: rows[0][0], item_count: rows[0][1]}
    end

    def self.summary_location(sierra_list)
        sql = <<-END_SQL.gsub(/\n/, '')
            SELECT
                location_code AS code,
                count(*) AS count
            FROM eco_details
            WHERE sierra_list = #{sierra_list}
            GROUP BY location_code
            ORDER BY  2 desc;
        END_SQL
        rows = ActiveRecord::Base.connection.exec_query(sql).rows

        summary = []
        rows.each do |r|
            summary << {code: r[0].upcase, count: r[1]}
        end
        summary
    end

    def self.summary_callnumber(sierra_list)
        sql = <<-END_SQL.gsub(/\n/, '')
            SELECT
                substring_index(callnumber_norm,' ', 1) AS code,
                count(*) AS count
            FROM eco_details
            WHERE sierra_list = #{sierra_list}
            GROUP BY substring_index(callnumber_norm,' ', 1)
            ORDER BY 2 DESC;
        END_SQL
        rows = ActiveRecord::Base.connection.exec_query(sql).rows

        summary = []
        rows.each do |r|
            summary << {code: r[0].upcase, count: r[1]}
        end
        summary
    end

    def self.summary_checkout(sierra_list)
        sql = <<-END_SQL.gsub(/\n/, '')
            SELECT checkout_total, count(checkout_total)
            FROM eco_details
            WHERE sierra_list = #{sierra_list}
            GROUP BY checkout_total
            ORDER BY 1 DESC;
        END_SQL
        rows = ActiveRecord::Base.connection.exec_query(sql).rows

        summary = []
        rows.each do |r|
            summary << {num: r[0], count: r[1]}
        end
        summary
    end

    def self.summary_fund_codes(sierra_list)
        sql = <<-END_SQL.gsub(/\n/, '')
            SELECT fund_code, fund_code_master, count(fund_code)
            FROM eco_details
            WHERE sierra_list = #{sierra_list}
            GROUP BY fund_code, fund_code_master
            ORDER BY 3 DESC, 1 ASC;
        END_SQL
        rows = ActiveRecord::Base.connection.exec_query(sql).rows

        summary = []
        rows.each do |r|
            summary << {fund_code: r[0], fund_code_master: r[1], count: r[2]}
        end
        summary
    end

    def self.summary_subjects(sierra_list)
        sql = <<-END_SQL.gsub(/\n/, '')
            SELECT substring_index(marc_value, '|', 2), count(id)
            FROM eco_details
            WHERE sierra_list = #{sierra_list}
            GROUP BY substring_index(marc_value, '|', 2)
            ORDER BY 2 DESC;
        END_SQL
        rows = ActiveRecord::Base.connection.exec_query(sql).rows

        summary = []
        rows.each do |r|
            summary << {subject: r[0], count: r[1]}
        end
        summary
    end
end