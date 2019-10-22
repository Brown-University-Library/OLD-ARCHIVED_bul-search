# -*- encoding : utf-8 -*-
#
require "./lib/http_json.rb"
class PullslipsController < ApplicationController
  def index
    render
  end

  def show
    @barcode_font = true
    @id = params["id"]
    if @id.to_i == 0
      Rails.logger.error("Invalid list ID received #{@id}")
      @results = []
    else
      @results = hay_data(@id)
    end
    case
    when params["format"] == "json"
      render :json => @results
    when params["format"] == "tsv"
      send_data(to_tsv(@results), :filename => "flags.tsv", :type => "text/tsv")
    else
      render
    end
  end

  def print
    @id = params["id"]
    if @id.to_i == 0
      Rails.logger.error("Invalid list ID received #{@id}")
      @results = []
    else
      @results = hay_data(@id)
    end
    @table = data_to_table(@results)
    render layout: false
  end

  def hay_flags
  end

  private
    def hay_data(id)
        Rails.cache.fetch("pullslips_#{id}", expires_in: 20.minute) do
            url = ENV["BIB_UTILS_SERVICE"] + "/bibutils/pullSlips?id=#{id}"
            Rails.logger.info("Loading Pull Slips from bibService #{url}")
            HttpUtil::HttpJson.get(url, [], 300)
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

    def data_to_table(data)
        table = []
        row = []
        i = 0
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
