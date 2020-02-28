class BestBetsController < ApplicationController
    def index
        if params[:format] == "tsv"
            @tsv = BestBetEntry.export_tsv()
            send_data(@tsv, :filename => "best_bets.tsv", :type => "text/tsv")
            return
        end

        @data = BestBetEntry.all.order(:name)
        render
    end

    def show()
    end
end