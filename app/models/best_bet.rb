require 'cgi'
require 'json'
require 'open-uri'
require 'rsolr'
require 'uri'

class BestBet
  include BlacklightHelper
  #
  # Get a best bet for the given query.
  # Return hash with keys expected by partial
  #
  def self.get(query = "")
    return nil if query.empty?
    query = query.strip
    match = self.get_from_solr(query)
    if match == nil
      match = self.get_from_reserves(query)
    end
    if ENV["CALLNUMBER_SHORTCUT"] == "true"
      if match == nil && query.start_with?("#")
        match = self.get_callnumber(query[1..-1])
      end
    end
    match
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    nil
  end

  def self.get_from_solr(query)
    solr_url = ENV['BEST_BETS_SOLR_URL']
    if solr_url == nil
      Rails.logger.warn "Skipped BestBet search (no BestBet Solr URL available)"
      return nil
    end

    # The default Ruby's HTTP timeout values are 60 seconds which is too
    # long and exacerbates server side issues when Solr is slow. Here we
    # shorten it so that we fail-fast rather than compound the problem.
    timeout_seconds = 2
    solr = RSolr.connect(:url => solr_url, :read_timeout => timeout_seconds, :open_timeout => timeout_seconds)
    qp = {
      :wt=>"json",
      "q"=>"\"#{query}\"",
      "qt" => 'search',
    }

    response = solr.get('search', :params => qp)
    if response["response"]["docs"].count == 1
      Rails.logger.warn "BestBet: more than one match found for (#{query})"
    end

    #Always take the first doc.
    response["response"]["docs"].each do |doc|
      return {
        :name => doc["name_display"],
        :url => doc["url_display"][0],
        :description => doc.fetch("description_display", [nil])[0]
      }
    end
    nil
  end

  def self.get_from_reserves(query)
    return nil if !self.is_course_number?(query)
    r = Reserves.new
    matches = r.courses_by_course_num(query)
    if matches.count == 0
      nil
    elsif matches.count == 1
      # Details URL
      #
      # This URL does not work in dev because of missing /find/
      # We should pass this prefix somehow to the model but
      # for now I don't want to pollute the model with route
      # information.
      return {
        :name => "#{matches[0].name}",
        :url => "/reserves/#{matches[0].classid}/#{matches[0].number_section_url}",
        :description => "Course reserves for: #{matches[0].name} (#{matches[0].number_section})"
      }
    else
      # Search URL
      # See note above about /find/
      return {
        :name => "#{matches[0].name} (multiple matches)",
        :url => "/reserves/?course_num=#{matches[0].number_url}",
        :description => "Course reserves for: #{matches[0].name} (#{matches[0].number_section})"
      }
    end
  end

  def self.is_course_number?(query)
    # starts with 3 to 5 characters, a space (optional), and 4 digits.
    regex = /^[A-Z]{3,5}\s?\d\d\d\d/
    return true if query.upcase.match(regex) != nil
    false
  end

  def self.get_callnumber(query)
    blacklight_config = Blacklight.default_configuration
    searcher = SearchCustom.new(blacklight_config)
    response, documents, match = searcher.callnumber(query)
    if documents.count == 1
      id = documents[0]["id"]
      title = documents[0]["title_display"]
      author = self.catalog_author_display(documents[0])
      return {
        :name => "Call number: #{match}",
        :url => "/catalog/#{id}",
        :description => "Call number for: #{title}/#{author}"
      }
    elsif documents.count > 1
      return {
        :name => "Call number: #{match}",
        :url => "/catalog?q=#{query}&search_field=call_number",
        :description => "Multiple matches were found"
      }
    end
    return nil
  end

  # This method is duplicated in app/helpers/blacklight_helpers.rb
  # TODO: Make a single one.
  def self.catalog_author_display document
    primary = document['author_display']
    if primary
      return primary
    else
      added = document['author_addl_display']
      if added
        return added[0]
      end
    end
  end
end
