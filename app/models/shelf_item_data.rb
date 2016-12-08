class ShelfItemData

  MIN_PAGES = 20
  MAX_PAGES = 1500
  MIN_HEIGHT = 15     # cm
  MAX_HEIGHT = 100    # cm

  attr_reader :id, :callnumbers, :creator, :title,
    :measurement_page_numeric, :measurement_height_numeric,
    :shelfrank, :pub_date, :isbn, :highlight, :link,
    :normalized
  attr_accessor :link, :title

  def initialize(id, callnumbers, author, title, pub_date, physical_display, isbns, normalized)
    @id = id
    @callnumbers = callnumbers || []
    @title = title || ""
    @creator = [author || ""]
    @measurement_page_numeric = get_pages(physical_display)
    @measurement_height_numeric = get_height(physical_display)
    @shelfrank = 15
    @pub_date = get_year(pub_date)
    @link = ""
    @highlight = false
    @isbn = (isbns || []).first()
    @normalized = normalized
  end

  def highlight=(value)
    @shelfrank = value ? 50 : 15
    @highlight = value
  end

  private
    def get_pages(physical_display)
      if physical_display != nil && physical_display.count > 0
        matches = physical_display.first.match("([0-9]*)\sp\.")
        if matches != nil && matches[1] != nil
          pages = matches[1].to_i
          if pages <= 0
            return MIN_PAGES
          elsif pages > MAX_PAGES
            return MAX_PAGES
          else
            return pages
          end
        end
      end
      MIN_PAGES
    end

    def get_height(physical_display)
      if physical_display != nil && physical_display.count > 0
        matches = physical_display.first.match("([0-9]*)\scm")
        if matches != nil && matches[1] != nil
          height = matches[1].to_i
          if height <= 0
            return MIN_HEIGHT
          elsif height >= MAX_HEIGHT
            return MAX_PAGES
          else
            return height
          end
        end
      end
      MIN_HEIGHT
    end

    def get_year(pub_date)
      return "" if pub_date == nil || pub_date.count == 0
      pub_date.first
    end
end
