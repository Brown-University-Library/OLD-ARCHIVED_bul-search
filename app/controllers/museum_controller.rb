class MuseumController < ApplicationController
  def thumbnail
    id = params[:id]
    return nil if id == "placeholder"

    if id.start_with?("MP_HAF_")
      id = id.gsub("MP_HAF_", "")
    end

    mp = MuseumPlus.new(ENV["MP_URL"], ENV["MP_USER"], ENV["MP_PASSWORD"])
    bytes = mp.thumbnail(id);
    send_data bytes, :type => "application/xml", :filename=>"thumb#{id}.jpg"
  end
end
