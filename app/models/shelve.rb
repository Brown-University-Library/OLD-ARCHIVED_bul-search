class Shelve
  def nearby_items(callnumber)
    @callnumber = Callnumber.new(callnumber)
    # search solr for callnumber = @callnumber.lc_subclass
    # plus
    # search solr for callnumber = @callnumber.subclass
    # and return an array of results
    []
  end
end
