# [Blacklight Override]
# Overriden to allow the e-mail feature to 
# process all bookmarks, not only the first 10.
class BookmarksController < CatalogController

  include Blacklight::Bookmarks
  MAX_BOOKMARKS_DISPLAY = 1000

  def action_documents
    bookmarks = token_or_current_or_guest_user.bookmarks
    bookmark_ids = bookmarks.collect { |b| b.document_id.to_s }
    blacklight_options = {rows: MAX_BOOKMARKS_DISPLAY}
    fetch(bookmark_ids, blacklight_options)
  end
end
