# -*- encoding : utf-8 -*-
#
require "./lib/http_json.rb"
class HayController < ApplicationController
  def flags
    @barcode_font = true
    @results = hay_data()
    case
    when params["format"] == "json"
      render :json => @results
    when params["format"] == "tsv"
      send_data(to_tsv(@results), :filename => "flags.tsv", :type => "text/tsv")
    else
      render
    end
  end

  def flags_print
    @table = hay_data_table()
    render layout: false
  end

  private
    def hay_data()
        Rails.cache.fetch("hay_query", expires_in: 20.minute) do
            url = ENV["BIB_UTILS_SERVICE"] + "/bibutils/hayQuery.json"
            Rails.logger.info("Loading Hay query data from bibService #{url}")
            HttpUtil::HttpJson.get(url)
        end
    end

    def to_tsv(data)
      header = data[0].keys.join("\t")
      tsv = header + "\tJosiahLink\r\n"
      data.each do |row|
        values = []
        row.keys.each do |key|
          values << row[key]
        end
        values << "http://search.library.brown.edu/catalog/#{row['BibRecordNum']}"
        tsv += values.join("\t") + "\r\n"
      end
      tsv
    end

    def hay_data_table()
        table = []
        row = []
        i = 0
        data = hay_data()
        data.each do |result|
          row << result
          i += 1
          if i == 3
            table << row
            row = []
            i = 0
          end
        end
        table
    end
end
