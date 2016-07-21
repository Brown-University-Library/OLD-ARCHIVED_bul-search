# -*- encoding : utf-8 -*-
# This module provides the body of an email export based on the document's semantic values

class BookmarkEMailInfo
  attr_accessor :title, :author, :format, :language,
                :url, :online_url_label, :online_url,
                :locations, :callnumbers
end

module Blacklight::Document::Email

  # Return a text string that will be the body of the email
  def to_email_text
    semantics = self.to_semantic_values
    body = []
    body << I18n.t('blacklight.email.text.title', value: semantics[:title].join(" ")) unless semantics[:title].blank?
    body << I18n.t('blacklight.email.text.author', value: semantics[:author].join(" ")) unless semantics[:author].blank?
    body << I18n.t('blacklight.email.text.format', value: semantics[:format].join(" ")) unless semantics[:format].blank?
    body << I18n.t('blacklight.email.text.language', value: semantics[:language].join(" ")) unless semantics[:language].blank?
    return body.join("\n") unless body.empty?
  end

  def to_email_info
    semantics = self.to_semantic_values
    info = BookmarkEMailInfo.new
    info.title = semantics[:title].join(" ")
    info.author = semantics[:author].join(" ")
    info.format = semantics[:format].join(" ")
    info.language = semantics[:language].join(" ")
    info.online_url = self[:url_fulltext_display].first if self[:url_fulltext_display]
    info.online_url_label = self[:url_suppl_display].first if self[:url_suppl_display]
    info.locations = self.location_names
    info.callnumbers = self[:callnumber_t]
    info
  end
end
