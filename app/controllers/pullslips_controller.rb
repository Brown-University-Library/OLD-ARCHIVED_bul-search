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
      data.each do |item|
        # Make the barcode readable by our scanners
        # (no spaces, surround with asterisks)
        item["BarCode"] = "*" + (item["BarCode"] || "").gsub(" ", "") + "*"
      end

      # Force to length of the array be a multiple of 3
      # (simplifies the algorithm of dumping them into a table with 3 columns)
      mod = (data.count % 3)
      if mod == 1
        data << nil
        data << nil
      elsif mod == 2
        data << nil
      end

      pages = data.count / 3
      table = []
      (1..pages).each do |page|
        i = (page-1) * 3
        row = [data[i], data[i+1], data[i+2]]
        table << row
      end

      table
    end
end
