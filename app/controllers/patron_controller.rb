# -*- encoding : utf-8 -*-
#
require "./lib/http_json"

class PatronController < ApplicationController
    def checkouts
        if !valid_credentials?(params)
            render :json => {}, status: 401
            return
        end
        patron_id = (params["patronId"] || "").to_i
        if patron_id == 0
            render :json => {}, status: 400
            return
        end

        data = patron_checkouts(params["patronId"])
        render :json => data
    end
  
    private
      def valid_credentials?(params)
        return params["token"] == ENV["PATRON_TOKEN"]
      end

      def patron_checkouts(patron_id)
        url = ENV["BIB_UTILS_SERVICE"] + "/bibutils/patron/checkout/?patronId=#{patron_id}"
        return HttpUtil::HttpJson.get(url)
      end
end
  