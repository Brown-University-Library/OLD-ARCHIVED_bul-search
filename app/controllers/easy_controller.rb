

class EasyController < ApplicationController
  def home
  end

  def search
    @search_result = Easy.new params[:q]
    #response.headers['Content-Type'] = 'text/javascript'
    render json: @search_result.to_json
    #body: @search_result.to_json, layout: false, content_type: "text/javascript"
  end
end
