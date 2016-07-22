# -*- encoding : utf-8 -*-
# [Blacklight Override]
# This class was overriden to add new fields that
# we want to include in the e-mail.
require "./lib/blacklight/document/bookmark_email_info"

module Blacklight::Document::Email

  # Return a text string that will be the body of the email
  # We don't use this method, but we leave it here in case
  # Blacklight does.
  def to_email_text
    semantics = self.to_semantic_values
    body = []
    body << I18n.t('blacklight.email.text.title', value: semantics[:title].join(" ")) unless semantics[:title].blank?
    body << I18n.t('blacklight.email.text.author', value: semantics[:author].join(" ")) unless semantics[:author].blank?
    body << I18n.t('blacklight.email.text.format', value: semantics[:format].join(" ")) unless semantics[:format].blank?
    body << I18n.t('blacklight.email.text.language', value: semantics[:language].join(" ")) unless semantics[:language].blank?
    return body.join("\n") unless body.empty?
  end

  # Returns an object with the information to be used in the
  # e-mail. This is what we use.
  def to_email_info
    semantics = self.to_semantic_values
    info = BookmarkEmailInfo.new
    info.title = semantics[:title].join(" ")
    info.author = semantics[:author].join(" ")
    info.format = semantics[:format].join(" ")
    info.language = semantics[:language].join(" ")
    info.online_url = self[:url_fulltext_display].first if self[:url_fulltext_display]
    info.online_url_label = self[:url_suppl_display].first if self[:url_suppl_display]
    info.locations = self.location_names
    info.callnumbers = self[:callnumber_t] || []
    info
  end
end
