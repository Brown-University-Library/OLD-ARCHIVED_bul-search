# -*- encoding : utf-8 -*-
#
# [Blacklight Override]
# This class was overriden to include availability
# information as part of the e-mail.
#
# This module provides the body of an email export based on the document's semantic values
require "./app/models/concerns/blacklight/document/bookmark_email_info"

module Blacklight::Document::Email
  # This is the default method that Blacklight calls.
  # We don't use it.
  def to_email_text
    Rails.logger.error("Call to Blacklight::Document::Email.e_mail_text detected: #{caller.join('\n')}")
    ""
  end

  # This is what we use instead. We return an object with the
  # information to be used on the e-mail.
  def to_email_info
    semantics = self.to_semantic_values
    info = BookmarkEmailInfo.new
    info.title = semantics[:title].join(" ")
    info.author = semantics[:author].join(" ")
    info.format = semantics[:format].join(" ")
    info.language = semantics[:language].join(" ")

    if self[:url_fulltext_json_s]
      full_text_links = JSON.parse(self[:url_fulltext_json_s])
      info.online_url = full_text_links.first["url"]
      info.online_url_label = full_text_links.first["text"]
    end

    info.locations = self.location_names
    info.callnumbers = self[:callnumber_t] || []
    availability = Availability.new
    info.items = availability.get_items(self[:id])
    info
  end
end
