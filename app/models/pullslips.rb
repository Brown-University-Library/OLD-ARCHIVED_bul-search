class Pullslips
    attr_reader :data, :id

    def initialize(id)
        @id = id
        @data = fetch_data(id)
    end

    def title
        return "" if @data.count == 0
        @data[0]["ProjectTitle"]
    end

    def list_date
        return "" if @data.count == 0
        @data[0]["ListDate"]["Time"] || ""
    end

    def list_date_human
      date = list_date
      return "" if date == ""
      date.to_time.to_s(:long)
    end

    def fetch_data(id)
        Rails.cache.fetch("pullslips_#{id}", expires_in: 1.hour) do
            url = ENV["BIB_UTILS_SERVICE"] + "/bibutils/pullSlips?id=#{id}"
            Rails.logger.info("Loading Pull Slips from bibService #{url}")
            data = HttpUtil::HttpJson.get(url, [], 300)
            data.each_with_index do |item, ix|
              item["PrintOrder"] = ix + 1
              item["CallNumber"] = (item["CallNumber"] || "").upcase
              # Make the barcode readable by our scanners
              # (no spaces, surround with asterisks)
              item["BarCodePrint"] = "*" + (item["BarCode"] || "").gsub(" ", "") + "*"
            end
            data
        end
    end

    def to_tsv()
      header = @data[0].keys.join("\t")
      tsv = header + "\tJosiahLink\r\n"
      @data.each do |row|
        values = []
        row.keys.each do |key|
          values << row[key]
        end
        values << "http://search.library.brown.edu/catalog/#{row['BibRecordNum']}"
        tsv += values.join("\t") + "\r\n"
      end
      tsv
    end

    def to_print_table()
      # Force to length of the array be a multiple of 3
      # (simplifies the algorithm of dumping them into a table with 3 columns)
      mod = (@data.count % 3)
      if mod == 1
        @data << nil
        @data << nil
      elsif mod == 2
        @data << nil
      end

      pages = @data.count / 3
      table = []
      (1..pages).each do |page|
        c1 = (page - 1)
        c2 = (pages * 1) + (page - 1)
        c3 = (pages * 2) + (page - 1)
        row = [@data[c1], @data[c2], @data[c3]]
        table << row
      end

      table
    end
end