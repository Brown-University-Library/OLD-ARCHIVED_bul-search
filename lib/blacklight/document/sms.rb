# -*- encoding : utf-8 -*-
module Blacklight::Document::Sms
  # Return a text string that will be the body of the email
  def to_sms_text
    semantics = self.to_semantic_values
    body = []
    body << I18n.t('blacklight.sms.text.title', value: semantics[:title].first) unless semantics[:title].blank?
    body << I18n.t('blacklight.sms.text.author', value: semantics[:author].first) unless semantics[:author].blank?

    availability = Availability.new
    items = availability.get_items(self[:id])
    items.each do |item|
      body << "\n#{item.location_text}" if item.location_text != nil
      body << "\n#{item.callnumber}" if item.callnumber != nil
    end
    return body.join unless body.empty?
  end
end
