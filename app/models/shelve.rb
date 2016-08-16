class ShelveSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  attr_reader :blacklight_config

  def initialize(blacklight_config, search_token, page, per_page)
    @blacklight_config = blacklight_config
    @search_token = search_token
    @page = page
    @per_page = per_page
    processor_chain = [:search_by_callnumber]
    scope = nil
    super(processor_chain, scope)
  end

  def search_by_callnumber(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "callnumber_t:#{@search_token}*"
    solr_parameters[:fl] ||= []
    solr_parameters[:fl] << "id"
    solr_parameters[:fl] << "callnumber_t"
    solr_parameters[:fl] << "title_display"
    solr_parameters[:fl] << "author_display"
    # TODO: include the year
    solr_parameters[:start] = (@page-1) * @per_page
    solr_parameters[:rows] = @per_page
  end
end

class ShelveItemData
  attr_reader :id, :callnumbers, :author, :title,
    :lc_class, :lc_subclass
  attr_accessor :highlight

  def initialize(id, callnumbers, author, title)
    @id = id
    @callnumbers = callnumbers || []
    @author = author || ""
    @title = title
    if callnumbers.count > 0
      # Pick the class/subclass from the first call number
      cn = Callnumber.new(callnumbers[0])
      @lc_class = cn.lc_class
      @lc_subclass = cn.lc_subclass
    end
    @highlight = false
  end
end


class Shelve
  def initialize(blacklight_config)
    @blacklight_config = blacklight_config
  end

  def nearby_items(callnumber)
    lc_subclass = Callnumber.new(callnumber).lc_subclass
    puts "==> Fetching this class #{lc_subclass}"
    items_in_subclass = nearby_by_subclass(lc_subclass)
    puts "    #{items_in_subclass.count} items found"
    before_items = []
    after_items = []

    index = index_for_callnumber(items_in_subclass, callnumber)
    if index == -1
      # TODO: not sure what to do here.
      # Are there too many items for this lc_subclass that
      # we didn't even get the item that we are on?
      return items_in_subclass
    end

    if index < 10
      # pick the last from the previous class...
      before_items = []
      more_items = fetch_prev_subclass(lc_subclass)
      more_items.last(10).each { |item| before_items << item }
      # ...plus everything from this class before the item.
      items_in_subclass.take(index).each do |item|
        before_items << item
      end
    else
      # pick the 10 closes to the item
      before_items = items_in_subclass[index-10..index-1]
    end

    if (index+10) > items_in_subclass.count
      # pick the closes afer the item...
      after_items = []
      items_in_subclass[index..-1].each { |item| after_items << item }
      # ...plus the first 10 from the next class
      more_items = fetch_next_subclass(lc_subclass)
      more_items.take(10).each { |item| after_items << item }
    else
      # pick the 10 closes to the item
      after_items = items_in_subclass[index+1..index+11]
    end

    items = []
    before_items.each { |item| items << item }
    items << items_in_subclass[index]
    after_items.each { |item| items << item }

    items.each do |item|
      if item.callnumbers.include?(callnumber)
        item.highlight = true
      end
    end
    items
  end

  private

    def nearby_by_subclass(lc_subclass)
      page = 1
      # TODO: this is pretty dangerous, we are fetching 10K items !!!
      per_page = 10000
      builder = ShelveSearchBuilder.new(@blacklight_config, lc_subclass, page, per_page)
      repository = Blacklight::SolrRepository.new(@blacklight_config)
      response = repository.search(builder)
      docs = filter_by_subclass(lc_subclass, response.documents)
      items = to_shelve_items(docs)
      sort_items(items)
    end

    # Due to the way our call numbers are indexed in Solr any query by
    # call number will return many false matches. For example, a search for
    # `call_number_t:M25` will return items with "M25" anywhere on the
    # call number (e.g. PC123 .M25 2000). This is because the callnumber_t
    # field is tokenized by Solr.
    #
    # This method removes those false matches. We only leave on the list
    # those documents where their call number subclass matches the one
    # that we want. We should be able to get rid of this code once we
    # update the way we index our call numbers in Solr.
    def filter_by_subclass(lc_subclass, documents)
      valid_docs = []
      documents.each do |doc|
        valid = false
        doc["callnumber_t"].each do |callnumber|
          if Callnumber.new(callnumber).lc_subclass == lc_subclass
            valid = true
          end
        end
        if valid
          valid_docs << doc
        end
      end
      valid_docs
    end

    def to_shelve_items(documents)
      items = []
      documents.each do |doc|
        item = ShelveItemData.new(doc["id"],
          doc["callnumber_t"], doc["author_display"], doc["title_display"])
        items << item
      end
      items
    end

    def sort_items(items)
      sorted = items.sort do |x,y|
        # TODO: include the year
        if x.lc_subclass == y.lc_subclass
          x.author <=> y.author
        else
          x.lc_subclass <=> y.lc_subclass
        end
      end
      sorted
    end

    def index_for_callnumber(items, callnumber)
      items.each_with_index do |item, index|
        item.callnumbers.each do |number|
          return index if number == callnumber
        end
      end
      -1
    end

    def fetch_prev_subclass(lc_subclass)
      loc_range = LocClassRange.new
      range = loc_range.find_next(lc_subclass)
      prev_subclass = range[:begin]
      puts "==> Fetching previous class #{prev_subclass}"
      documents = nearby_by_subclass(prev_subclass)
      puts "    #{documents.count} items found"
      documents
    end

    def fetch_next_subclass(lc_subclass)
      loc_range = LocClassRange.new
      range = loc_range.find_next(lc_subclass)
      next_subclass = range[:end]
      puts "==> Fetching next class #{next_subclass}"
      documents = nearby_by_subclass(next_subclass)
      puts "    #{documents.count} items found"
      documents
    end
end
