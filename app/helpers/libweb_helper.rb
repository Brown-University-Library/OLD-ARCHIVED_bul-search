module LibwebHelper
    def libweb_more(query)
        link_to("More results", libweb_more_link(query))
    end

    def libweb_more_link(query)
        url_for :controller=>'libweb', :action=> 'search', :q => query
    end
end
