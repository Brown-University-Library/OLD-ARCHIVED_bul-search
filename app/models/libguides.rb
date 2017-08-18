class Libguides
  def initialize
    @api_url = ENV["LIBGUIDES_API_URL"]
    raise "No value for LIBGUIDES_API_URL was found the environment" if @api_url == nil
  end

  def cache_update()
    errors = []
    begin
      guides = HttpUtil::HttpJson.get(@api_url)
      if guides.count == 0
        # Don't update the cache if we couldn't fetch the source data
        errors << "Could not fetch data from LibGuides"
      else
        # Deletes the cache and re-populates it
        LibguidesCache.delete_all
        guides.each do |guide|
          c = LibguidesCache.new
          c.name = guide["tagName"]
          c.url = guide["libguideUrl"]
          c.guide_type = guide["tagType"]
          if !c.save()
            errors << "Could not save guide #{guide["tagName"]}."
          end
        end
      end
    rescue => e
      errors << "#{e.message}"
    end
    errors
  end

  # Course should be in the form XXXXnnnnYYY (e.g. ANTH0110S01)
  def self.lib_guide(course)
    return nil if course == nil
    cache = LibguidesCache.find_by_name("C-#{course[0..7]}")
    if cache != nil
      cache.url
    else
      nil
    end
  end

  # Course should be in the form XXXXnnnn (e.g. ANTH0110)
  def self.subject_guide(course)
    return nil if course == nil
    cache = LibguidesCache.find_by_name("S-#{course[0..3]}")
    if cache != nil
      cache.url
    else
      nil
    end
  end
end
