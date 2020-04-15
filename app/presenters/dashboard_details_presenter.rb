class DashboardDetailsPresenter
    attr_accessor :summary, :name, :count, :rows, :from, :to,
        :download_url, :show_all_url, :edit_user

    def initialize(summary, name = nil, count = nil, rows = nil)
        @rows = rows
        @count = count
        @summary = summary
        @name = name
        @from = nil
        @to = nil
        @download_url = nil
        @show_all_url = nil
        @edit_user = false
    end

    def is_partial_list?
        @rows.count < @count
    end

    def shib_url(url)
        if @edit_user
            return (url || "")
        end
        "https://search.library.brown.edu/users/auth/shibboleth?target=" + (url || "")
    end
end