class Callnumber < ActiveRecord::Base

  # Number of books on the shelf to show before/after the current book.
  NEARBY_BATCH_SIZE = 5

  # Max number of records to fetch at once when cacheing BIBs/call numbers.
  SOLR_BATCH_SIZE = 1000

  # Saves to the callnumber table all the BIB id
  # and original call numbers found in Solr.
  #
  # Notice that we are not normalizing the call numbers here. We use
  # an external Python program for that. (See misc/callnumber_norm/)
  def self.cache_bib_ids_to_table(blacklight_config, page = 1)
    puts "Cacheing BIB record IDs (starting on page #{page})..."
    while true
      ActiveRecord::Base.connection.execute("START TRANSACTION")
      batch, total_docs = self.get_batch(blacklight_config, page)
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
  #
  # Notice that we are not normalizing the call numbers here. We use
  # an external Python program for that. (See misc/callnumber_norm/)
  def self.cache_bib_ids_to_file(blacklight_config, page = 1)
    filename = "callnumbers_upsert.sql"
    IO.write(filename, "", mode: "w")
    while true
      batch, total_docs = self.get_batch(blacklight_config, page)
      sql_tx = "SELECT #{page}, #{page_count(total_docs)};\r\n"
      sql_tx << "START TRANSACTION;\r\n"
      batch.each do |row|
        sql = <<-END_SQL.gsub(/\n/, '')
          INSERT IGNORE INTO callnumbers(bib, original)
          VALUES("#{row[:bib]}","#{row[:original]}")
        END_SQL
        sql_tx << sql + ";\r\n"
      end
      sql_tx << "COMMIT;\r\n"
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
    return {ids: [], bounds: boundaries(nil, nil)} if callnumber == nil

    # Items with call numbers _before_ or equal to this BIB.
    sql = <<-END_SQL.gsub(/\n/, '')
      select bib, normalized
      from callnumbers
      where normalized <= "#{callnumber.normalized}"
      order by normalized desc
      limit #{NEARBY_BATCH_SIZE};
    END_SQL
    before_rows = ActiveRecord::Base.connection.exec_query(sql).rows

    # Items with call numbers _after_ this bib_id.
    sql = <<-END_SQL.gsub(/\n/, '')
      select bib, normalized
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
    before_rows.reverse!
    before_rows.each do |r|
      ids << {id: r[0], normalized: r[1]}
    end

    if ids.find {|id| id == bib_id} == nil
      # If the current BIB was not in the list we force it
      # to be on the list. This could happen when we have
      # too many items with the same call number.
      ids << {id: bib_id, normalized: callnumber.normalized}
    end

    after_rows.each do |r|
      ids << {id: r[0], normalized: r[1]}
    end

    return {ids: ids, bounds: boundaries(before_rows, after_rows)}
  end


  def self.next_id(bib_id, skip_count)
    callnumber = Callnumber.find_by(bib: bib_id)
    return nil if callnumber == nil

    if skip_count > 0
      sql = <<-END_SQL.gsub(/\n/, '')
        select bib, normalized
        from callnumbers
        where normalized >= "#{callnumber.normalized}" and bib <> "#{bib_id}"
        order by normalized
        limit #{skip_count};
      END_SQL
      rows = ActiveRecord::Base.connection.exec_query(sql).rows
      return nil if rows.count == 0
      return rows.last[0]
    elsif skip_count < 0
      sql = <<-END_SQL.gsub(/\n/, '')
        select bib, normalized
        from callnumbers
        where normalized <= "#{callnumber.normalized}" and bib <> "#{bib_id}"
        order by normalized desc
        limit #{skip_count.abs};
      END_SQL
      rows = ActiveRecord::Base.connection.exec_query(sql).rows
      return nil if rows.count == 0
      return rows.last[0]
    else
      # bib_id or nil?
      return bib_id
    end
  end

  # Returns an array of BIB record IDs with call numbers
  # that are BEFORE to the bib_id provided.
  def self.nearby_ids_prev(bib_id, normalized)
    callnumber = Callnumber.find_by(bib: bib_id, normalized: normalized)
    return {ids: [], bounds: boundaries(nil, nil)} if callnumber == nil

    # Items with call numbers _before_ or equal to this BIB.
    sql = <<-END_SQL.gsub(/\n/, '')
      select bib, normalized
      from callnumbers
      where normalized <= "#{callnumber.normalized}" and bib <> "#{bib_id}"
      order by normalized desc
      limit #{NEARBY_BATCH_SIZE};
    END_SQL
    before_rows = ActiveRecord::Base.connection.exec_query(sql).rows
    before_rows.reverse!
    ids = before_rows.map do |r|
      {id: r[0], normalized: r[1]}
    end
    return {ids: ids, bounds: boundaries(before_rows, nil)}
  end

  # Returns an array of BIB record IDs with call numbers
  # that are AFTER to the bib_id provided.
  def self.nearby_ids_next(bib_id, normalized)
    callnumber = Callnumber.find_by(bib: bib_id, normalized: normalized)
    return {ids: [], bounds: boundaries(nil, nil)} if callnumber == nil

    # Items with call numbers _after_ this bib_id.
    sql = <<-END_SQL.gsub(/\n/, '')
      select bib, normalized
      from callnumbers
      where normalized > "#{callnumber.normalized}"
      order by normalized
      limit #{NEARBY_BATCH_SIZE};
    END_SQL
    after_rows = ActiveRecord::Base.connection.exec_query(sql).rows
    ids = after_rows.map do |r|
      {id: r[0], normalized: r[1]}
    end
    return {ids: ids, bounds: boundaries(nil, after_rows)}
  end

  private
    def self.fetch_all_solr_ids(blacklight_config, page, page_size)
      builder = AllIdsSearchBuilder.new(blacklight_config, page, page_size)
      repository = Blacklight::SolrRepository.new(blacklight_config)
      response = repository.search(builder)
      return response.documents, response["response"]["numFound"]
    end

    def self.fetch_some_solr_ids(blacklight_config, ids)
      builder = SomeIdsSearchBuilder.new(blacklight_config, ids)
      repository = Blacklight::SolrRepository.new(blacklight_config)
      response = repository.search(builder)
      response.documents
    end

    def self.get_batch(blacklight_config, page)
      batch = []
      solr_docs, total_docs = self.fetch_all_solr_ids(blacklight_config, page, SOLR_BATCH_SIZE)
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
      return batch, total_docs
    end

    def self.page_count(total_docs)
      count = (total_docs / SOLR_BATCH_SIZE).to_i
      if (total_docs % SOLR_BATCH_SIZE) > 0
        count += 1
      end
      count
    end

    def self.boundaries(top_rows, bottom_rows)
      top = nil
      bottom = nil
      return {top: top, bottom: bottom}
      if top_rows && top_rows.count > 0
        top = top_rows.first[1]
      end
      if bottom_rows && bottom_rows.count > 0
        bottom = bottom_rows.last[1]
      end
      return {top: top, bottom: bottom}
    end
end
