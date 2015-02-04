require 'json'
require 'openssl'
require 'open-uri'


module BdrDisplay

  def item_api_url
    "#{ENV['BDR_ITEM_API_URL']}#{self.id}/"
  end

  def grab_item_api_data
    response = open(self.item_api_url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
    JSON.parse(response.read)
  end

  def item
    self.grab_item_api_data
  end

end