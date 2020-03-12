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
      if id == "-1"
        return fetch_fake(id)
      end
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

    def fetch_fake(id)
      a = {"FlagDate"=>{"Time"=>"2020-03-11T00:00:00Z", "Valid"=>true}, "DisplayOrder"=>1, "ProjectTitle"=>"BH LOW CIC PQ_FOR FLAGS (02-14-2020)", "ListDate"=>{"Time"=>"2020-02-14T11:23:02.8-05:00", "Valid"=>true}, "OrderNum"=>"o1478975a", "CallNumber"=>"DG  441 I87 2009", "CopyNum"=>1, "Volume"=>"", "BarCode"=>"3 1236 09290 0466", "Code2"=>"-", "ItemStatusCode"=>"-", "BibRecordNum"=>"b5178167a", "ItemRecordNum"=>"i15182986a", "LocalTag"=>" SPM", "Title"=>"Italy and the classical tradition :", "Edition"=>"", "Publisher"=>"London :Duckworth,2009", "PubYear"=>"2009", "Author"=>"", "Description"=>"x, 269 p. :ill. ;24 cm", "ItemLocation"=>"rock", "LocalNotes"=>"", "BndWith"=>false, "PrintOrder"=>1, "BarCodePrint"=>"*31236092900466*"}
      b = {"FlagDate"=>{"Time"=>"2020-03-11T00:00:00Z", "Valid"=>true}, "DisplayOrder"=>2, "ProjectTitle"=>"BH LOW CIC PQ_FOR FLAGS (02-14-2020)", "ListDate"=>{"Time"=>"2020-02-14T11:23:02.8-05:00", "Valid"=>true}, "OrderNum"=>"o1348222a", "CallNumber"=>"PQ 2664 U812 P48 X 2005", "CopyNum"=>1, "Volume"=>"", "BarCode"=>"3 1236 01840 4924", "Code2"=>"-", "ItemStatusCode"=>"-", "BibRecordNum"=>"b3673448a", "ItemRecordNum"=>"i13112039a", "LocalTag"=>" SPM", "Title"=>"La petite fille et la cigarette :", "Edition"=>"", "Publisher"=>"[Paris] :Fayard,c2005", "PubYear"=>"2005", "Author"=>"Duteurtre, Benoît, 1960-", "Description"=>"214 p. ;22 cm", "ItemLocation"=>"rock", "LocalNotes"=>"", "BndWith"=>false, "PrintOrder"=>2, "BarCodePrint"=>"*31236018404924*"}
      [a, b, a, b, a, b, a, b]
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