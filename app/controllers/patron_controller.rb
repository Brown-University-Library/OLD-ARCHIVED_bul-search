# -*- encoding : utf-8 -*-
#
require "./lib/http_json"

class PatronController < ApplicationController
    skip_before_filter :verify_authenticity_token

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

        data = patron_checkouts(patron_id)
        render :json => data
    end
  
    private
      def valid_credentials?(params)
        return params["token"] == ENV["PATRON_TOKEN"]
      end

      def patron_checkouts(patron_id)
        key = "patron_checkouts_" + patron_id.to_s
        Rails.cache.fetch(key, expires_in: 2.minute) do
            url = ENV["BIB_UTILS_SERVICE"] + "/bibutils/patron/checkout/?patronId=#{patron_id}"
            Rails.logger.info("Loading Patron Checkouts from Sierra #{url}")
            HttpUtil::HttpJson.get(url)
        end
      end
end
  