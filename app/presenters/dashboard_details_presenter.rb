class DashboardDetailsPresenter
    attr_accessor :summary, :name, :count, :rows, :from, :to,
        :download_url, :show_all_url

    def initialize(summary, name, count, rows)
        @rows = rows
        @count = count
        @summary = summary
        @name = name
        @from = nil
        @to = nil
        @download_url = nil
        @show_all_url = nil
    end

    def is_partial_list?
        @rows.count < @count
    end
end