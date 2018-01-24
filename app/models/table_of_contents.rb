class TableOfContents

  def initialize toc_970_display, toc_display
    if !toc_970_display.nil?
      @toc_info = JSON.parse(toc_970_display[0])
    elsif !toc_display.nil?
      @toc_info = JSON.parse(toc_display[0])
    else
      raise Exception.new('no TableOfContents info')
    end
    @chapters = make_chapters
  end

  def make_chapters
    chapters = []
    @toc_info.each do |chapter|
      ['label', 'indent', 'title', 'page'].each do |key|
        chapter[key] = "" if chapter[key].nil?
      end
      chapter['authors'] = [] if chapter['authors'].nil?
      chapters << chapter
    end
    chapters
  end

  def chapters
    @chapters
  end

end
