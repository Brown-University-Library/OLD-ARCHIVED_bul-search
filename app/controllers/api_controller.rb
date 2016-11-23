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
    documents = shelf.nearby_items(id)
    nearby_response = { id: id, documents: documents }
    render :json => nearby_response
  end

  def items_nearby2
    id = UserInput::Cleaner.clean_id(params[:id])
    if id.empty?
      return render_error("No id provided.")
    end
    shelf = Shelf.new(blacklight_config)
    documents = shelf.nearby_items(id)
    byebug
    json_docs = documents.map do |d|
      {
        title: d.title,
        creator: [d.author],
        measurement_page_numeric: d.pages,
        measurement_height_numeric: d.height,
        shelfrank: d.highlight ? 50 : 15,
        pub_date: d.year,
        link: "#{catalog_url(d.id)}?nearby",
        isbn: d.isbn,
        highlight: d.highlight
      }
    end
    nearby_response = {
      start: "-1",
      num_found: "0",
      limit: "0",
      docs: json_docs
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
