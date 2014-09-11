module BdrHelper
  require 'json'
  require 'openssl'
  require 'open-uri'

  def bdr_grab_item_api_data(doc)
    url = "#{ENV['BDR_ITEM_API_URL']}#{doc.id}/"
    response = open(url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
    bdr_item = JSON.parse(response.read)
  end
end
