class ReservesBook
  attr_accessor :bib, :callno, :title, :author, :loan_term, :personal
  def self.from_hash(hash)
    rb = ReservesBook.new()
    if hash["bib"] && hash["bib"].length == 8 && hash["bib"][0] == "b"
      # only use the bib number if it looks like a bib number
      rb.bib = hash["bib"]
    end
    rb.callno = (hash["callno"] || "").strip
    rb.title = hash["title"]
    rb.author = hash["author"]
    rb.loan_term = hash["loan_term"]
    rb.personal = hash["personal"] # item is the personal copy of the professor
    rb
  end

  def callno_search
    return nil if callno == nil
    search_value = callno.strip
    index = (search_value =~ /\w* c\.\d+/)
    if index != nil
      # strip the copy value (e.g. c.2 or c.3)
      search_value = (search_value[0..(index-1)] || "").strip
    end
    search_value
  end
end
