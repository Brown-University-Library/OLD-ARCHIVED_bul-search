module Blacklight::Document::Email
  class BookmarkEmailInfo
    attr_accessor :title, :author, :format, :language,
                  :url, :online_url_label, :online_url,
                  :locations, :callnumbers, :items
  end
end
