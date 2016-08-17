class ShelveSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  attr_reader :blacklight_config

  def initialize(blacklight_config, begin_range, end_range)
    @blacklight_config = blacklight_config
    @begin_range = begin_range
    @end_range = end_range
    # TODO: this is pretty dangerous, we are fetching 10K items !!!
    @page = 1
    @per_page = 10000
    processor_chain = [:search_by_callnumber]
    scope = nil
    super(processor_chain, scope)
  end

  def search_by_callnumber(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "callnumber_t:[#{@begin_range} TO #{@end_range}]"
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
      @lc_class, @lc_subclass = Callnumber.loc_class(callnumbers[0])
    end
    @highlight = false
  end
end


class Shelve
  attr_reader :target_subclass
  attr_reader :prev_subclass_begin, :prev_subclass_end
  attr_reader :next_subclass_begin, :next_subclass_end

  def initialize(blacklight_config)
    @blacklight_config = blacklight_config
  end

  def nearby_items(callnumber, id)
    Callnumber.
    _, lc_subclass = Callnumber.loc_class(callnumber)
    @target_subclass = lc_subclass
    items_in_subclass = nearby_by_subclass(lc_subclass, lc_subclass)
    before_items = []
    after_items = []
    index = index_for_id(items_in_subclass, id)
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

    items.each { |item| item.highlight = true if item.id == id }
    items
  end

  private

    def nearby_by_subclass(begin_subclass, end_subclass)
      builder = ShelveSearchBuilder.new(@blacklight_config, begin_subclass, end_subclass)
      repository = Blacklight::SolrRepository.new(@blacklight_config)
      response = repository.search(builder)
      docs = filter_by_subclass(begin_subclass, end_subclass, response.documents)
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
    def filter_by_subclass(begin_subclass, end_subclass, documents)
      valid_docs = []
      documents.each do |doc|
        valid = false
        doc["callnumber_t"].each do |callnumber|
          _, lc_subclass = Callnumber.loc_class(callnumber)
          if lc_subclass >= begin_subclass && lc_subclass <= end_subclass
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

    def index_for_id(items, id)
      items.each_with_index do |item, index|
        return index if item.id == id
      end
      -1
    end

    def fetch_prev_subclass(lc_subclass)
      # TODO: recurse call if no documents fetch
      loc_range = LocClassRange.new
      range = loc_range.find_next(lc_subclass)
      return [] if range == nil
      subclass_begin = range[:begin]
      subclass_end = range[:end]
      @prev_subclass_begin = subclass_begin
      @prev_subclass_end = subclass_end
      documents = nearby_by_subclass(subclass_begin, subclass_end)
      documents
    end

    def fetch_next_subclass(lc_subclass)
      # TODO: recurse call if no documents fetch
      loc_range = LocClassRange.new
      range = loc_range.find_next(lc_subclass)
      return [] if range == nil
      subclass_begin = range[:begin]
      subclass_end = range[:end]
      @next_subclass_begin = subclass_begin
      @next_subclass_end = subclass_end
      documents = nearby_by_subclass(subclass_begin, subclass_end)
      documents
    end
end
