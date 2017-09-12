require 'cgi'
require 'json'
require 'open-uri'
require 'summon'
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

    solr = RSolr.connect(:url => solr_url)
    qp = {
      :wt=>"json",
      "q"=>"\"#{query}\"",
      "qt" => 'search',
    }

    response = solr.get('search', :params => qp)
    if response[:response][:docs].count == 1
      Rails.logger.warn "BestBet: more than one match found for (#{query})"
    end

    #Always take the first doc.
    response[:response][:docs].each do |doc|
      return {
        :name => doc[:name_display],
        :url => doc[:url_display][0],
        :description => doc.fetch(:description_display, [nil])[0]
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
    # starts with 4 characters, a space (optional), and 4 digits.
    regex = /^[A-Z][A-Z][A-Z][A-Z]\s?\d\d\d\d/
    query.upcase.match(regex) != nil
  end
end
