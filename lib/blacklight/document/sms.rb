# -*- encoding : utf-8 -*-
module Blacklight::Document::Sms

  def parse_location_text availability_info
    location_text = nil
    begin
      item_data = availability_info['items'].first
      if item_data['location']
        location_text = "Location: #{item_data['location']}"
        if item_data['shelf']
          location_text += " -- Level #{item_data['shelf']['floor']}, Aisle #{item_data['shelf']['aisle']}"
        end
      end
    rescue
      # no biggie
      location_text = nil
    end
    location_text
  end

  def parse_location_call_number availability_info
    begin
      item_data = availability_info['items'].first
      call_number = item_data['callnumber']
    rescue
      # no biggie
      call_number = nil
    end
    call_number
  end

  # Return a text string that will be the body of the email
  def to_sms_text
    semantics = self.to_semantic_values
    body = []
    body << I18n.t('blacklight.sms.text.title', value: semantics[:title].first) unless semantics[:title].blank?
    body << I18n.t('blacklight.sms.text.author', value: semantics[:author].first) unless semantics[:author].blank?
    availability_info = self.get_availability_info
    call_number = parse_location_call_number availability_info
    body << "\n#{call_number}" unless call_number.nil?
    location = parse_location_text availability_info
    body << "\n#{location}" unless location.nil?
    return body.join unless body.empty?
  end

end
