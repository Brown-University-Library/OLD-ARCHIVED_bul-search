class EcoDetails < ActiveRecord::Base
    def josiah_bib_id
        "b#{bib_record_num}"
    end

    # Creates a tab delimited string for a set of EcoDetails rows
    def self.to_tsv(rows)
        str = "#\tbib\titem\ttitle\t" +
            "pub_year\tpublisher\tloc_code\t" +
            "checkouts\tcall_no\tsubject\t" +
            "order\tfund\tfund_master\r\n"
        rows.each_with_index do |row, i|
            line = "#{i+1}\t#{row.josiah_bib_id}\t#{row.item_record_num}\t#{row.title}\t"
            line += "#{row.publish_year}\t#{row.publisher}\t#{row.location_code}\t"
            line += "#{row.checkout_total}\t#{row.callnumber_raw}\t#{row.marc_value}\t"
            line += "#{row.ord_record_num}\t#{row.fund_code}\t#{row.fund_code_master}"
            str += line + "\r\n"
        end
        str
    end
end