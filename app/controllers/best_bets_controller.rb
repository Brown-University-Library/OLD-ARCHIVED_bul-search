class BestBetsController < ApplicationController
    # skip_before_filter :verify_authenticity_token

    def index
        @page_title = "Best Bets"
        @edit_user = edit_user?

        if params[:format] == "tsv"
            if @edit_user
                @tsv = BestBetEntry.export_tsv()
                send_data(@tsv, :filename => "best_bets.tsv", :type => "text/tsv")
            else
                send_data("Must be authenticated", :filename => "best_bets.tsv", :type => "text/tsv")
            end
            return
        end

        @data = BestBetEntry.all_cached()
        render
    end

    def edit()
        id = params[:id]
        @edit_user = edit_user?
        if !@edit_user
            raise "Invalid user"
        end
        @data = BestBetEntry.find(id)
        @page_title = "Best Bets - #{@data.name}"
        render
    rescue => ex
        Rails.logger.error("Error editing BestBet #{ex}")
        render "error"
    end

    def save()
        @edit_user = edit_user?
        if !@edit_user
            raise "Invalid user"
        end
        id = params["id"]
        BestBetEntry.save_form(params)
        url = best_bets_index_url() + "#" + id
        redirect_to url
    rescue => ex
        Rails.logger.error("Error saving BestBet #{ex}")
        render "error"
    end

    def delete()
        @edit_user = edit_user?
        if !@edit_user
            raise "Invalid user"
        end
        id = params["id"]
        bb = BestBetEntry.find(id)
        bb.delete()
        redirect_to best_bets_index_url()
    rescue => ex
        Rails.logger.error("Error deleting BestBet #{ex}")
        render "error"
    end

    private
        def edit_user?
            # TODO: remove for production
            if (request.env["REQUEST_URI"] || "").start_with?("http://localhost:3000/bestbets")
                return true
            end

            return false if current_user == nil
            user = "/#{current_user}/"
            return (ENV["BEST_BETS_USERS"] || "").include?(user)
        end
end