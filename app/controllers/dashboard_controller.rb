# -*- encoding : utf-8 -*-
#
require "./lib/http_json.rb"
class DashboardController < ApplicationController
  def index
    render
  end

  def show
    @info = load_subject(params["subject"])
    if @info == nil
        render text: "Invalid subject"
        return
    end
    render
  end

  def details
    @info = load_subject(params["subject"])
    if @info == nil
        render text: "Invalid subject"
        return
    end

    @page = (params["page"] || "").to_i
    @page = (@page < 1) ? 1 : @page
    @page_size = 1000
    @start = (@page - 1) * @page_size
    @stop = (@start - 1 ) + @page_size
    if @stop > @info[:count] - 1
      @stop = @info[:count] - 1
    end
    @page_next = @page + 1
    @page_prev = @page -1

    case
    when params["format"] == "json"
      render :json => @info[:data]
    when params["format"] == "tsv"
      send_data(to_tsv(@info[:data]), :filename => "#{@info[:key]}.tsv", :type => "text/tsv")
    else
      render
    end
  end

  private
    def load_subject(subject)
      if subject != "econ"
        return nil
      end
      info = {
        key: "econ",
        name: "Economics Pilot",
        list: 344,
        items: sierra_data(subject)
      }
      info[:count] = info[:items].count
      info[:percent] = ((info[:count] / 4810620.00) * 100).round(2)
      return info
    end

    def sierra_data(subject)
        Rails.cache.fetch("dashboard_#{subject}", expires_in: 1.day) do
            url = ENV["BIB_UTILS_SERVICE"] + "/collection/details?subject=#{subject}"
            Rails.logger.info("Loading data from bibService #{url}")
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
end
