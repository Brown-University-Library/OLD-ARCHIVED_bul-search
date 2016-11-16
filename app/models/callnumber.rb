class Callnumber < ActiveRecord::Base
  NEARBY_BATCH_SIZE = 10            # num. records before/after to fetch
  SOLR_BATCH_SIZE = 1000            # max number of record to fetch at once

  # Saves to the callnumber table all the BIB id
  # and original call numbers found in Solr.
  # Notice that we don't normalize the call numbers
  # here, see normalize_all_pending for that.
  def self.cache_all_bib_ids(blacklight_config, page = 1)
    puts "Cacheing all BIB record IDs..."
    page_size = SOLR_BATCH_SIZE
    while true
      added = 0
      solr_docs = self.fetch_all_solr_ids(blacklight_config, page, page_size)
      Callnumber.transaction do
        solr_docs.each do |solr_doc|
          callnumbers = solr_doc["callnumber_t"] || []
          callnumbers.each do |callnumber|
            # TODO: handle longer call numbers
            next if callnumber.length > 50
            records = Callnumber.where(bib: solr_doc["id"], original: callnumber)
            if records.count == 0
              record = Callnumber.new
              record.original = callnumber
              record.bib = solr_doc["id"]
              record.save!
              added += 1
            end
          end
        end
      end
      puts "\tpage #{page}, added #{added} rows"
      last_page = solr_docs.count < page_size
      break if last_page
      page += 1
    end
  end


  def self.normalize_one(blacklight_config, id)
    solr_docs = self.fetch_some_solr_ids(blacklight_config, [id])
    raise "ID #{id} not found in Solr." if solr_docs.count == 0
    raise "More than one BIB record found in Solr for ID: #{id}" if solr_docs.count > 1
    # Process the callnumber for the BIB record...
    callnumbers = solr_doc[0]["callnumber_t"] || []
    callnumbers.each do |callnumber|
      normalized = CallnumberNormalizer.normalize_one(callnumber)
      records = Callnumber.where(bib: id, original: callnumber)
      case records.count
      when 0
        # add the record to the DB
        record = Callnumber.new
        record.original = callnumber
        record.bib = id
        record.normalized = normalized
        record.save!
      when 1
        # update the existing record
        record[0].normalized = normalized
        record[0].save!
      else
        raise "More than row found for #{id}/#{callnumber} in the database"
      end
    end
  end


  # Returns an array of BIB record IDs with call numbers
  # that are near to the bib_id provided.
  def self.nearby_ids(bib_id)
    # How should we handle if have more than one call number
    # for a given BIB record and they have different LOC
    # classifications? (see BIB b3093842 and b7777507)
    #
    # For now, we just fetch the first one.
    callnumber = Callnumber.find_by(bib: bib_id)
    return [] if callnumber == nil

    # Items with call numbers _before_ or equal to this BIB.
    sql = <<-END_SQL.gsub(/\n/, '')
      select bib
      from callnumbers
      where normalized <= "#{callnumber.normalized}"
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
    # Notice that we reverse the _before items_ first
    # so they show correctly (lower on top).
    ids = []
    before_rows.reverse.each { |r| ids << r[0] }

    if ids.find {|id| id == bib_id} == nil
      # If the current BIB was not in the list we force it
      # to be on the list. This could happen when we have
      # too many items with the same call number.
      ids << bib_id
    end

    after_rows.each { |r| ids << r[0] }
    ids
  end

  private
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
