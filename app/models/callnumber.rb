class Callnumber < ActiveRecord::Base

  NEARBY_BATCH_SIZE = 10            # num. records before/after to fetch
  NORMALIZE_API_THROTTLE = 0.20     # seconds
  NORMALIZE_API_BATCH_SIZE = 100    # max number of callnumbers to pass at once
  SOLR_BATCH_SIZE = 100             # max number of record to fetch at once

  def self.normalize_one(blacklight_config, id)
    solr_docs = self.fetch_some_solr_ids(blacklight_config, [id])
    solr_docs.each do |solr_doc|
      callnumbers = solr_doc["callnumber_t"] || []
      callnumbers.each do |callnumber|
        # Make sure this BIB/call_number exists in the DB...
        records = Callnumber.where(bib: id, original: callnumber)
        if records.count == 0
          record = Callnumber.new
          record.original = callnumber
          record.bib = id
          record.save!
        end
      end
      # ...and then normalize them
      self.normalize_many(callnumbers)
    end
  end


  # Saves to the callnumber table all the BIB id
  # and original call numbers found in Solr.
  # Notice that we don't normalize the call numbers
  # here, see normalize_all_pending for that.
  def self.cache_all_bib_ids(blacklight_config)
    puts "Cacheing all BIB record IDs..."
    page = 1
    page_size = SOLR_BATCH_SIZE
    while true
      puts "\tprocessing page #{page}"
      solr_docs = self.fetch_all_solr_ids(blacklight_config, page, page_size)
      solr_docs.each do |solr_doc|
        Callnumber.transaction do
          callnumbers = solr_doc["callnumber_t"] || []
          callnumbers.each do |callnumber|
            records = Callnumber.where(bib: solr_doc["id"], original: callnumber)
            if records.count == 0
              record = Callnumber.new
              record.original = callnumber
              record.bib = solr_doc["id"]
              record.save!
            end
          end
        end
      end
      last_page = solr_docs.count < page_size
      break if last_page
      page += 1
    end
  end

  # Calculates the normalized call number for all
  # records that don't have one.
  def self.normalize_all_pending
    next_id = 0
    while true
      puts "Processing after ID #{next_id}"
      sql = <<-END_SQL.gsub(/\n/, '')
        select id, original
        from callnumbers
        where normalized is null and id is not null and id > #{next_id}
        order by id
        limit #{NORMALIZE_API_BATCH_SIZE};
      END_SQL
      pending_rows = ActiveRecord::Base.connection.execute(sql)
      break if pending_rows.count == 0
      callnumbers = pending_rows.map { |row| row["original"] }
      self.normalize_many(callnumbers)
      next_id = pending_rows.last["id"]
    end
  end

  # Returns an array of items with call numbers that
  # are near to the bib_id provided.
  def self.nearby_ids(bib_id)
    # find_by returns only one record
    #   callnumber = Callnumber.find_by(bib: bib_id)
    #   callnumber[0]
    #   => #<CallNumber...>
    #
    # where() returns all records (as an ActiveRecord::Relation)
    #   callnumber = Callnumber.where(bib: bib_id)
    #   callnumber[0]
    #   => #<CallNumber...>
    #
    # How should we handle if there are more than one
    # call number and they have different LOC classifications?
    # (see BIB b3093842)
    callnumber = Callnumber.find_by(bib: bib_id)
    return [] if callnumber == nil

    # Items with call numbers _before_ this bib_id.
    sql = <<-END_SQL.gsub(/\n/, '')
      select bib
      from callnumbers
      where normalized < "#{callnumber.normalized}"
      order by normalized desc
      limit #{NEARBY_BATCH_SIZE};
    END_SQL
    before_rows = ActiveRecord::Base.connection.exec_query(sql).rows

    # Items with call numbers _after_ this bib_id.
    sql = <<-END_SQL.gsub(/\n/, '')
      select bib
      from callnumbers
      where normalized > "#{callnumber.normalized}"
      order by normalized
      limit #{NEARBY_BATCH_SIZE};
    END_SQL
    after_rows = ActiveRecord::Base.connection.exec_query(sql).rows

    # Join before and after rows.
    #
    # Notice that we revert the _before items_ first
    # so they show correctly (lower on top).
    ids = []
    before_rows.reverse.each { |r| ids << r[0] }
    ids << bib_id
    after_rows.each { |r| ids << r[0] }
    ids
  end

  def self.normalize_many(callnumbers)
    normalized_list = CallnumberNormalizer.normalize_many(callnumbers)
    sleep(NORMALIZE_API_THROTTLE) if NORMALIZE_API_THROTTLE > 0

    matches = match_callnumbers(callnumbers, normalized_list)
    matches.each do |match|

      records = Callnumber.where(original: match[:callnumber])
      if records.count == 0
        # We expect them to already be in the DB. See normalize_all_pending
        # and normalize_many. This should be refactored to remove that
        # dependency.
        raise "Call number to normalize (#{callnumber}) not in the database."
      end

      # Notice that is possible to get multiple matches because
      # sometimes more than one BIB record has the same call number.
      # This is particularly true when we only have LOC call numbers
      # and not Brown call numbers.
      records.each do |record|
        record.normalized = match[:normalized]
        record.save!
        puts "#{match[:callnumber]} -> #{match[:normalized]} for bid #{record.bib} (#{record.id})"
      end

    end
  end

  private

    def self.match_callnumbers(callnumbers, normalized_list)
      matches = []
      callnumbers.each do |callnumber|
        result = normalized_list.find {|n| n.callnumber == callnumber }
        if result && result.normalized != nil
          matches << {callnumber: callnumber, normalized: result.normalized}
        else
          puts "\tcallnumber #{callnumber} was not normalized"
        end
      end
      matches
    end

    def self.fetch_all_solr_ids(blacklight_config, page, page_size)
      builder = AllIdsSearchBuilder.new(blacklight_config, page, page_size)
      repository = Blacklight::SolrRepository.new(blacklight_config)
      response = repository.search(builder)
      response.documents
    end

    def self.fetch_some_solr_ids(blacklight_config, ids)
      builder = SomeIdsSearchBuilder.new(blacklight_config, ids)
      repository = Blacklight::SolrRepository.new(blacklight_config)
      response = repository.search(builder)
      response.documents
    end
end
