class BestBetsController < ApplicationController
    # TODO: Remove this once we enable authentication
    skip_before_filter :verify_authenticity_token

    def index
        if params[:format] == "tsv"
            @tsv = BestBetEntry.export_tsv()
            send_data(@tsv, :filename => "best_bets.tsv", :type => "text/tsv")
            return
        end

        @data = BestBetEntry.all_ordered()
        render
    end

    def edit()
        id = params[:id]
        @data = BestBetEntry.find(id)
        render
    rescue => ex
        Rails.logger.error("Error editing BestBet #{ex}")
        render "error"
    end

    def save()
        render "error"
        # =================
        # Disabled for now
        # =================
        # id = params["id"]
        # BestBetEntry.save_form(params)
        # url = best_bets_index_url() + "#" + id
        # redirect_to url
    end
end