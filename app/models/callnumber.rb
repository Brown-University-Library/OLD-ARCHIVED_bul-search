class Callnumber < ActiveRecord::Base
  NEARBY_BATCH_SIZE = 5             # num. records before/after to fetch
  SOLR_BATCH_SIZE = 1000            # max number of record to fetch at once

  # Saves to the callnumber table all the BIB id
  # and original call numbers found in Solr.
  # Notice that we don't normalize the call numbers
  # here, see normalize_all_pending for that.
  def self.cache_bib_ids_to_table(blacklight_config, page = 1)
    puts "Cacheing all BIB record IDs..."
    while true
      ActiveRecord::Base.connection.execute("START TRANSACTION")
      batch = self.get_batch(blacklight_config, page)
      batch.each do |row|
        sql = <<-END_SQL.gsub(/\n/, '')
          INSERT IGNORE INTO callnumbers(bib, original)
          VALUES("#{row[:bib]}","#{row[:original]}")
        END_SQL
        ActiveRecord::Base.connection.execute(sql)
      end
      ActiveRecord::Base.connection.execute("COMMIT")
      last_page = batch.count < SOLR_BATCH_SIZE
      break if last_page
      page += 1
    end
  end

  # Saves to a file on disk the SQL INSERT statementes to
  # add cache all the BIB id and original call numbers found in Solr.
  # This file can be submitted to MySQL with from the command
  # line with: mysql < callnumbers_upsert.sql
  def self.cache_bib_ids_to_file(blacklight_config, page = 1)
    filename = "callnumbers_upsert.sql"
    IO.write(filename, "", mode: "w")
    while true
      sql_tx = "START TRANSACTION;\r\n"
      batch = self.get_batch(blacklight_config, page)
      batch.each do |row|
        sql = <<-END_SQL.gsub(/\n/, '')
          INSERT IGNORE INTO callnumbers(bib, original)
          VALUES("#{row[:bib]}","#{row[:original]}")
        END_SQL
        sql_tx += sql + ";\r\n"
      end
      sql_tx += "COMMIT;\r\n"
      IO.write(filename, sql_tx, mode: "a")
      last_page = batch.count < SOLR_BATCH_SIZE
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

    def self.get_batch(blacklight_config, page)
      batch = []
      solr_docs = self.fetch_all_solr_ids(blacklight_config, page, SOLR_BATCH_SIZE)
      solr_docs.each do |solr_doc|
        callnumbers = solr_doc["callnumber_t"] || []
        callnumbers.uniq { |c| c.upcase }.each do |callnumber|
          bib = solr_doc["id"].gsub('"', '')
          if callnumber.length > 100
            puts "Ignored BIB: #{bib}, call number too long [#{callnumber}]"
            next
          end
          original = callnumber.upcase.gsub('"', '').gsub('\\', '')
          batch << {bib: bib, original: original}
        end
      end
      batch
    end
end
