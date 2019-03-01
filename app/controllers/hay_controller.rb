# -*- encoding : utf-8 -*-
#
require "./lib/http_json.rb"
class HayController < ApplicationController
  def list
    @barcode_font = true
    @results = hay_data()
    if params["format"] == "json"
      render :json => @results
    else
      render
    end
  end

  def print
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
