# -*- encoding : utf-8 -*-
#
require "./lib/http_json.rb"
class PullslipsController < ApplicationController
  def index
    render
  end

  def show
    @barcode_font = true
    id = params["id"]
    if id.to_i == 0
      Rails.logger.error("Invalid list ID received #{id}")
      raise "Invalid id"
    end
    @ps = Pullslips.new(id)
    case
    when params["format"] == "json"
      render :json => @ps.data
    when params["format"] == "tsv"
      send_data(@ps.to_tsv(), :filename => "flags.tsv", :type => "text/tsv")
    else
      render
    end
  end

  def print
    id = params["id"]
    if id.to_i == 0
      Rails.logger.error("Invalid list ID received #{id}")
      raise "Invalid id"
    end
    @ps = Pullslips.new(id)
    @table = @ps.to_print_table()
    render layout: false
  end
end
