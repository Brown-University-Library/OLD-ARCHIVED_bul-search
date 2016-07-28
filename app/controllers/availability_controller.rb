# This controller routes call to Brown's
# Availability Service.
#
# WARNING: This controller is not intended to be used in production.
#
# The reason we have this controller is because some of
# the calls to the Availability Service are issued via
# AJAX HTTP POST calls in which the browser enforces the
# same-domain restriction. Those calls work OK in production
# because this site and the Availabilty Service live on the
# same domain, however, that is not the case in our development
# environment. By having a proxy controller (like this one)
# within the application we can issue those POST calls in our
# development environment and test the code before we deploy
# to production.
class AvailabilityController < ApplicationController

  BROWN_AVAILABILITY_SERVICE_URL = "https://apps.library.brown.edu/bibutils/bib"

  # Returns a fake response for a single hard coded id.
  def fake_one
    render :json => one_record_stub
  end

  # Returns a fake response for 10 coded ids.
  def fake_many
    render :json => many_records_stub
  end

  # Forwards the call to get availability for a single ID
  # to the real Availability Service.
  #
  # ```
  # curl http://localhost:3000/availability/forward/b7272444
  # ```
  def forward_one
    id = params[:id]
    full_url = "#{BROWN_AVAILABILITY_SERVICE_URL}/#{id}/"
    uri = URI.parse(full_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if params[:callback]
      json_response = params[:callback]+ "(" + response.body + ")"
    else
      json_response = response.body
    end
    render :json => json_response
  end

  # Forwards the call to get availability for an array
  # of IDs to the real Availability Service.
  #
  # ```
  # curl -X POST http://localhost:3000/availability/forward \
  # -H "Content-Type: application/x-www-form-urlencoded" \
  # -d "[\"b2267763\",\"b7272444\"]"
  # ```
  def forward_many
    full_url = "#{BROWN_AVAILABILITY_SERVICE_URL}/"
    uri = URI.parse(full_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    # This is a horrible way of getting the original body
    # of the request but, since Rails is doing its magic
    # and parsing the body into the params object, we are
    # forced to get it out this other way.
    body_to_send = @_request.body.read
    request.body = body_to_send
    response = http.request(request)
    render :json => response.body
  end

  private

    def one_record_stub
      json_response = <<-eos
        {
          "b1150584": {
            "has_more": false,
            "items": [
              {
                "barcode": "31236001611295",
                "callnumber": "PN1998.A3 D5854",
                "location": "ROCK",
                "scan": "https://library.brown.edu/easyscan/request/?callnumber=BX4700.F33+S32&barcode=31236080139671",
                "item_request_url": "http://hectorwashere/",
                "map": "https://apps.library.brown.edu/bibutils/map/?loc=rock&call=PN1998.A3%20D5854",
                "shelf": {
                  "aisle": "27B",
                  "display_aisle": "27",
                  "floor": "B",
                  "located": true,
                  "location": "rock",
                  "side": "B"
                },
                "status": "AVAILABLE"
              }
            ],
            "more_link": "?limit=false",
            "requestable": true,
            "summary": []
          }
        }
        eos
    end

    def many_records_stub
      json_response = <<-eos
        {
          "b1150584": {
            "has_more": false,
            "items": [
              {
                "barcode": "31236001611295",
                "callnumber": "PN1998.A3 D5854",
                "location": "ROCK",
                "scan": "https://library.brown.edu/easyscan/request/?callnumber=BX4700.F33+S32&barcode=31236080139671",
                "item_request_url": "http://hectorwashere/",
                "map": "https://apps.library.brown.edu/bibutils/map/?loc=rock&call=PN1998.A3%20D5854",
                "shelf": {
                  "aisle": "27B",
                  "display_aisle": "27",
                  "floor": "B",
                  "located": true,
                  "location": "rock",
                  "side": "B"
                },
                "status": "AVAILABLE"
              }
            ],
            "more_link": "?limit=false",
            "requestable": true,
            "summary": []
          },
          "b1308937": {
            "has_more": false,
            "items": [
              {
                "barcode": "31236004382324",
                "callnumber": "PE1075 .C47 1983",
                "location": "ROCK",
                "map": "https://apps.library.brown.edu/bibutils/map/?loc=rock&call=PE1075%20.C47%201983",
                "shelf": {
                  "aisle": "16B",
                  "display_aisle": "16",
                  "floor": "B",
                  "located": true,
                  "location": "rock",
                  "side": "B"
                },
                "status": "AVAILABLE"
              }
            ],
            "more_link": "?limit=false",
            "requestable": true,
            "summary": []
          },
          "b1069010": {
            "has_more": false,
            "items": [
              {
                "barcode": "31236080139671",
                "callnumber": "BX4700.F33 S32",
                "location": "ANNEX",
                "scan": "https://library.brown.edu/easyscan/request/?callnumber=BX4700.F33+S32&barcode=31236080139671",
                "status": "AVAILABLE"
              }
            ],
            "more_link": "?limit=false",
            "requestable": true,
            "summary": []
          },
          "b1613922": {
            "has_more": false,
            "items": [
              {
                "barcode": "31236081838321",
                "callnumber": "QB723.O4 R34",
                "location": "ANNEX",
                "scan": "https://library.brown.edu/easyscan/request/?callnumber=QB723.O4+R34&barcode=31236081838321",
                "status": "AVAILABLE"
              }
            ],
            "more_link": "?limit=false",
            "requestable": true,
            "summary": []
          },
          "b1616709": {
            "has_more": false,
            "items": [
              {
                "barcode": "31236001637449",
                "callnumber": "1-SIZE QC84 .L75",
                "location": "ANNEX",
                "scan": "https://library.brown.edu/easyscan/request/?callnumber=1-SIZE+QC84+.L75&barcode=31236001637449",
                "status": "AVAILABLE"
              }
            ],
            "more_link": "?limit=false",
            "requestable": true,
            "summary": []
          },
          "b1654500": {
            "has_more": false,
            "items": [
              {
                "barcode": "31236081943378",
                "callnumber": "QP801.T3 J3",
                "location": "SCI",
                "map": "https://apps.library.brown.edu/bibutils/map/?loc=sci&call=QP801.T3%20J3",
                "shelf": {
                  "aisle": "7A",
                  "display_aisle": "7",
                  "floor": "13",
                  "located": true,
                  "location": "sci",
                  "side": "A"
                },
                "status": "UNAVAILABLE"
              }
            ],
            "more_link": "?limit=false",
            "requestable": false,
            "summary": []
          },
          "b1657828": {
            "has_more": false,
            "items": [
              {
                "barcode": "31236004562586",
                "callnumber": "R131 .G65 1964",
                "location": "ANNEX",
                "scan": "https://library.brown.edu/easyscan/request/?callnumber=R131+.G65+1964&barcode=31236004562586",
                "status": "AVAILABLE"
              }
            ],
            "more_link": "?limit=false",
            "requestable": true,
            "summary": []
          },
          "b1817267": {
            "has_more": false,
            "items": [
              {
                "barcode": "31236081159215",
                "callnumber": "PD3065 .D5",
                "location": "ANNEX",
                "scan": "https://library.brown.edu/easyscan/request/?callnumber=PD3065+.D5&barcode=31236081159215",
                "status": "AVAILABLE"
              }
            ],
            "more_link": "?limit=false",
            "requestable": true,
            "summary": []
          },
          "b1836161": {
            "has_more": false,
            "items": [
              {
                "barcode": "",
                "callnumber": "PJ4025 .R2",
                "location": "ROCK",
                "map": "https://apps.library.brown.edu/bibutils/map/?loc=rock&call=PJ4025%20.R2",
                "shelf": {
                  "aisle": "87A",
                  "display_aisle": "87",
                  "floor": "3",
                  "located": true,
                  "location": "rock",
                  "side": "A"
                },
                "status": "AVAILABLE"
              }
            ],
            "more_link": "?limit=false",
            "requestable": true,
            "summary": []
          },
          "b6062718": {
            "has_more": false,
            "items": [
              {
                "barcode": "31236096371037",
                "callnumber": "GV1785.N57 N44 1965",
                "location": "ROCK",
                "map": "https://apps.library.brown.edu/bibutils/map/?loc=rock&call=GV1785.N57%20N44%201965",
                "shelf": {
                  "aisle": "66A",
                  "display_aisle": "66",
                  "floor": "3",
                  "located": true,
                  "location": "rock",
                  "side": "A"
                },
                "status": "AVAILABLE"
              }
            ],
            "more_link": "?limit=false",
            "requestable": true,
            "summary": []
          }
        };
        return the_result;
      }
      eos
    end
end
