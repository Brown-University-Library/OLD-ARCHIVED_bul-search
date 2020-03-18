# Methods to store callnumbers and normalize them in the
# callnumber SQL table.
class CallnumberCache < ActiveRecord::Base

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
      puts "processing page #{page}..."
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

  def self.cache_bib_ids_since(start_date)
    page = 1
    while true
      docs, num_pages = self.get_updated_since(start_date, page)
      puts "Processing page #{page}/#{num_pages}"
      docs.each do |doc|
        bib = doc[:bib]
        callnumber = doc[:callnumber]
        records = Callnumber.where(bib: bib, original: callnumber)
        if records.count == 0
          record = Callnumber.new
          record.bib = bib
          record.original = callnumber
          record.normalized = nil
          record.save!
        end
      end
      page += 1
      break if page > num_pages
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
    # Process the callnumbers for the BIB record...
    callnumbers = solr_docs[0]["callnumber_t"] || []
    callnumbers.each do |callnumber|
      puts "Normalizing #{id}/#{callnumber}"
      normalized = CallnumberNormalizer.normalize_one(callnumber, false)
      if normalized == nil
        normalized = "ERR"
      end
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
        records[0].normalized = normalized
        records[0].save!
      else
        raise "Skipped #{id}/#{callnumber}, more than one row found in the database"
      end
    end
  end

  def self.normalize_pending(blacklight_config)
    puts "Fetching records to normalize..."
    records = Callnumber.where(normalized: nil)
    records.each do |record|
      begin
        normalize_one(blacklight_config, record.bib)
      rescue StandardError => e
        puts "#{e}, (continuing with the next one)"
      end
    end
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

    # Return an array of (bib + callnumbers) that have been updated in
    # to Solr after a given date.
    #
    # We use Solr's field `updated_dt` to determine what records that have been
    # updated. `updated_dt` indicates the last time the record was updated in
    # Millennium whereas Solr's `timestamp` indicates the last time the record
    # was touched in Solr and it almost always means the date the record was
    # imported into Solr.
    def self.get_updated_since(start_date, page = 1)
      # get the solr documents from Solr...
      solr_url = ENV['SOLR_URL']
      solr = SolrLite::Solr.new(solr_url)
      start_date_time = start_date.to_s + "T00:00:00.0Z"
      q = "updated_dt:[#{start_date_time} TO *]"
      fq = []
      facets = []
      params = SolrLite::SearchParams.new(q, fq, facets)
      params.page = page
      params.page_size = SOLR_BATCH_SIZE
      params.fl = ["id", "updated_dt", "callnumber_t", "title_display"]
      params.sort = "id asc"
      response = solr.search(params)

      # Extract the BIB + callnumber from each solr_doc
      # (a BIB record can have more than one callnumber)
      results = []
      response.solr_docs.each do |doc|
        (doc["callnumber_t"] || []).each do |callnumber|
          results << {bib: doc["id"], callnumber: callnumber}
        end
      end

      return results, response.num_pages
    end
end
