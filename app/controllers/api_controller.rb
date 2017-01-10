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
    id = UserInput::Cleaner.clean_id(params[:id])
    if id.empty?
      return render_error("No id provided.")
    end
    shelf = Shelf.new(blacklight_config)
    case params[:block]
    when "next"
      normalized = UserInput::Cleaner.clean(params[:normalized])
      documents = shelf.nearby_items_next(id, normalized)
    when "prev"
      normalized = UserInput::Cleaner.clean(params[:normalized])
      documents = shelf.nearby_items_prev(id, normalized)
    else
      documents = shelf.nearby_items(id)
    end
    documents.each do |d|
      d.link = "#{catalog_url(d.id)}?nearby"
    end

    nearby_response = {
      start: "0",
      num_found: documents.count.to_s,
      limit: "0",
      docs: documents
    }
    render :json => nearby_response
  end

  def shelf_items
    id = UserInput::Cleaner.clean_id(params[:id])
    if id.empty?
      return render_error("No id provided.")
    end
    start = get_start_skip(params[:query])
    init_id = Callnumber.next_id(id, start)
    if init_id == nil
      documents = []
    else
      verbose = params.has_key?("verbose") ? "verbose" : nil
      shelf = Shelf.new(blacklight_config)
      documents = shelf.nearby_items(init_id)
      documents.each do |d|
        if verbose != nil
          d.title = d.title + "<br/>" + d.id + ": " + d.callnumbers.join(",")
        end
        d.link = "#{catalog_url(d.id)}"
        d.highlight = (d.id == id)
      end
    end
    nearby_response = {
      start: "0",
      num_found: (documents.count).to_s,   # TODO: adjust this number
      limit: "0",
      docs: documents
    }
    render :json => nearby_response
  end

  def shelf_item
    id = UserInput::Cleaner.clean_id(params[:id])
    if id.empty?
      return render_error("No id provided.")
    end
    response, doc = fetch params[:id]
    item = {
      id: doc[:id],
      title: doc[:title_display] || "",
      author: doc[:author_display] || "",
      imprint: doc.marc_display_field("imprint"),
      isbns: doc[:isbn_t] || [],
      oclcs: doc[:oclc_t] || []
    }
    render :json => item
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

    # We expect range_str to be in the form "[n TO m]"
    # where n and m are integers (positive or negative)
    def get_start_skip(range_str)
      return 0 if range_str == nil
      reg_ex = /\[(-?(\d)*)\s/
      matches = reg_ex.match(range_str)
      return 0 if matches == nil || matches.length < 2
      matches[1].to_i
    end
end
