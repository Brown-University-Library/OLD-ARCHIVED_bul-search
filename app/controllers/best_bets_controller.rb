class BestBetsController < ApplicationController
    # TODO: Remove this once we enable authentication
    skip_before_filter :verify_authenticity_token

    def index
        if params[:format] == "tsv"
            @tsv = BestBetEntry.export_tsv()
            send_data(@tsv, :filename => "best_bets.tsv", :type => "text/tsv")
            return
        end

        @page_title = "Best Bets"
        @data = BestBetEntry.all_cached()
        render
    end

    def edit()
        id = params[:id]
        @data = BestBetEntry.find(id)
        @page_title = "Best Bets - #{@data.name}"
        render
    rescue => ex
        Rails.logger.error("Error editing BestBet #{ex}")
        render "error"
    end

    def save()
        if ENV["BEST_BETS_EDIT"] != "true"
            Rails.logger.error("BestBet edit not allowed")
            render "error"
            return
        end
        id = params["id"]
        BestBetEntry.save_form(params)
        url = best_bets_index_url() + "#" + id
        redirect_to url
    end

    def delete()
        if ENV["BEST_BETS_EDIT"] != "true"
            Rails.logger.error("BestBet edit not allowed")
            render "error"
            return
        end
        id = params["id"]
        bb = BestBetEntry.find(id)
        bb.delete()
        redirect_to best_bets_index_url()
    end
end