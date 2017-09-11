# Handles legacy viewFind URLs
class LegacyController < ApplicationController
    def search
      redirect_to easyS_path(), status: 302
    end
    def search_results
      if params["filter"] != nil
        filter = Array(params["filter"]).first
        if filter == "collection:Brown University Dissertations"
          url = catalog_url(id:"") + "?f[format][]=Thesis/Dissertation&q="
          redirect_to url, status: 302
          return
        end
      end
      redirect_to easyS_path(), status: 302
    end
end
