require "./lib/log_util.rb"

# Methods to store callnumbers and normalize them in the
# callnumber SQL table.
class CallnumberCache < ActiveRecord::Base

  # Saves to the callnumber table all the BIB ids found in Solr,
  # their call numbers, and the normalized version of the call
  # numbers.
  def self.cache_bib_ids_to_table(page = 1)
    solr_batch_size = 200000
    total_pages = nil
    while true
      puts "Processing page #{page} / #{total_pages}"
      batch, total_pages = self.get_batch(page, solr_batch_size)

      ActiveRecord::Base.connection.execute("START TRANSACTION")
      batch.each do |row|
        normalized = CallnumberNormalizer.normalize_one(row[:callnumber])
        if normalized == nil
          normalized = "NULL"
        else
          normalized = '"' + normalized + '"'
        end
        sql = <<-END_SQL.gsub(/\n/, '')
          INSERT IGNORE INTO callnumbers(bib, original, normalized)
          VALUES("#{row[:bib]}","#{row[:callnumber]}", #{normalized})
        END_SQL
        ActiveRecord::Base.connection.execute(sql)
      end
      ActiveRecord::Base.connection.execute("COMMIT")

      break if (page >= total_pages)
      page += 1
    end
  end

  # Saves to the call number table BIB ids in Solr that have
  # been added since a given date, and normalize their call number
  # information.
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
          record.normalized = CallnumberNormalizer.normalize_one(callnumber)
          record.save!
        end
      end
      page += 1
      break if page > num_pages
    end
    nil
  end

  # Saves to a file on disk the SQL INSERT statementes to
  # add cache all the BIB ids found in Solr, their original
  # call numbers, and the normalized version of those call
  # numbers.
  #
  # This file can be submitted to MySQL with from the command
  # line with: mysql < callnumbers_upsert.sql
  def self.cache_bib_ids_to_file(page = 1)
    solr_batch_size = 200000
    total_pages = nil
    filename = "callnumbers_upsert.sql"
    IO.write(filename, "", mode: "w")
    while true
      puts "Processing page #{page} / #{total_pages}"
      batch, total_pages = self.get_batch(page, solr_batch_size)

      sql_tx = "SELECT #{page};\r\n"
      sql_tx << "START TRANSACTION;\r\n"
      batch.each do |row|
        normalized = CallnumberNormalizer.normalize_one(row[:callnumber])
        if normalized == nil
          normalized = "NULL"
        else
          normalized = '"' + normalized + '"'
        end
        sql = <<-END_SQL.gsub(/\n/, '')
          INSERT IGNORE INTO callnumbers(bib, original, normalized)
          VALUES("#{row[:bib]}","#{row[:callnumber]}", #{normalized})
        END_SQL
        sql_tx << sql + ";\r\n"
      end
      sql_tx << "COMMIT;\r\n"
      IO.write(filename, sql_tx, mode: "a")

      break if (page >= total_pages)
      page += 1
    end
  end

  def self.normalize_bib(id)
    # Get the call numbers for the bib...
    solr = SolrLite::Solr.new(ENV['SOLR_URL'])
    doc = solr.get(id, "q", "callnumber_t")
    raise "ID #{id} not found in Solr." if doc == nil
    callnumbers = doc["callnumber_t"] || []

    # ...delete previous records for this bib
    Callnumber.delete_all(bib: id)

    # ..and save the normalized records
    callnumbers.each do |callnumber|
      normalized = CallnumberNormalizer.normalize_one(callnumber)
      record = Callnumber.new
      record.original = callnumber
      record.bib = id
      record.normalized = normalized
      record.save!
    end
  end

  private
    # Returns an array of bib + callnumbers for all the Solr docs.
    def self.get_batch(page, solr_batch_size)
      solr_url = ENV['SOLR_URL']
      solr = SolrLite::Solr.new(solr_url)
      params = SolrLite::SearchParams.new("id:*")
      params.page = page
      params.page_size = solr_batch_size
      params.fl = ["id", "callnumber_t"]
      params.sort = "id asc"
      response = solr.search(params)

      batch = []
      response.solr_docs.each do |solr_doc|
        callnumbers = (solr_doc["callnumber_t"] || []).uniq { |c| c.upcase }
        callnumbers.each do |callnumber|
          if callnumber.length > 100
            next
          end
          callnumber = callnumber.upcase.gsub('"', '').gsub('\\', '')
          batch << {bib: solr_doc["id"], callnumber: callnumber}
        end
      end
      return batch, response.num_pages
    end

    # Returns an array of bib + callnumbers for all the Solr docs
    # that have been updated after a given data.
    #
    # We use Solr's field `updated_dt` to determine what records that have been
    # updated because this field indicates the last time the record was updated
    # in Sierra. Field `timestamp` indicates the last time the record was
    # imported into Solr.
    def self.get_updated_since(start_date, page = 1, solr_batch_size = 1000)
      solr_url = ENV['SOLR_URL']
      solr = SolrLite::Solr.new(solr_url)
      start_date_time = start_date.to_s + "T00:00:00.0Z"
      q = "updated_dt:[#{start_date_time} TO *]"
      params = SolrLite::SearchParams.new(q)
      params.page = page
      params.page_size = solr_batch_size
      params.fl = ["id", "updated_dt", "callnumber_t"]
      params.sort = "id asc"
      response = solr.search(params)

      results = []
      response.solr_docs.each do |doc|
        callnumbers = (doc["callnumber_t"] || []).uniq {|c| c.upcase }
        callnumbers.each do |callnumber|
          results << {bib: doc["id"], callnumber: callnumber}
        end
      end

      return results, response.num_pages
    end
end
