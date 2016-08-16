# -*- encoding : utf-8 -*-
#
require "./lib/user_input.rb"

class ApiController < ApplicationController
  include Blacklight::Catalog

  # TODO: figure out a better way to configure Solr
  # without having to include Blacklight::Catalog
  configure_blacklight do |config|
    config.default_solr_params = {
      :qt => 'search',
      :rows => 10,
      :spellcheck => false
    }
  end

  def items_by_location
    code = params[:code] || ""
    if code.empty?
      return render_error("No location code provided (code)")
    end

    item = Item.new(blacklight_config)
    code = UserInput::Cleaner.clean(code)
    response = item.by_location(code, page, per_page)
    render :json => response.documents
  end

  def items_nearby
    callnumber = params[:callnumber] || ""
    id = params[:id] || ""
    if callnumber.empty? || id.empty?
      return render_error("No call number (callnumber) or id provided.")
    end
    shelve = Shelve.new(blacklight_config)
    callnumber = UserInput::Cleaner.clean(callnumber)
    documents = shelve.nearby_items(callnumber, id)

    nearby_response = {
      id: id,
      callnumber: callnumber,
      lc_subclass: shelve.target_subclass,
      prev_subclass: "#{shelve.prev_subclass_begin} - #{shelve.prev_subclass_end}",
      next_subclass: "#{shelve.next_subclass_begin} - #{shelve.next_subclass_end}",
      documents: documents
    }
    render :json => nearby_response
  end

  private
    def page
      int_param(:page, 1)
    end

    def per_page
      int_param(:per_page, 10, 1000)
    end

    def render_error(message)
      render status: 400, :json => "{\"error\": \"#{message}\"}"
    end
end
