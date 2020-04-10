# Methods to browse through call numbers.
# This class should be renamed to CallnumberBrowse
class Callnumber < ActiveRecord::Base

  # Number of books on the shelf to show before/after the current book.
  NEARBY_BATCH_SIZE = 5

  # Returns the best call number an array of call numbers and a
  # given range. This is useful when a record has many call
  # numbers and we are interested in the call number for a given
  # range.
  #
  # For example, bib record https://search.library.brown.edu/catalog/b7953880
  # has two call numbers "KF3467" and "HD6060.5.U6". If the range is
  # "HD" to "HD" the second one would be returned.
  def self.best_for_range(call_numbers, norm_from, norm_to)
    normalized = []
    call_numbers.each do |raw|
        norm = CallnumberNormalizer.normalize_one(raw)
        if Callnumber.in_range?(norm, norm_from, norm_to)
            # returns the first call number that can be normalized
            # and it's in the indicated range
            return {raw: raw, norm: norm}
        end
        normalized << {raw: raw, norm: norm}
    end

    if normalized.count > 0
        # returns the first call number that can be normalized
        return normalized.first
    end

    # return the first one
    return {raw: call_numbers.first, norm: nil}
  end


  # Returns true if a normalized call number is within
  # a given call number range
  def self.in_range?(norm, norm_from, norm_to)
    return false if norm == nil

    # Handle single class range (e.g. HB to HB)
    if norm_from == norm_to
      return norm.start_with?(norm_from)
    end

    # Typcal ranges (e.g. T 56.8 to	T 58.3)
    norm >= norm_from && norm <= norm_to
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

  # Fetches the bib records that match a given call number range
  # and yields so that the caller can process them.
  def self.process_by_range(cn_from, cn_to)
    is_range, norm_from, norm_to = CallnumberNormalizer.normalize_range(cn_from, cn_to)
    if !is_range
      Rails.logger.warn("process_by_range: Invalid call number range #{cn_from} / #{cn_to}")
      yield []
    end

    solr_url = ENV['SOLR_URL']
    solr = SolrLite::Solr.new(solr_url)
    params = SolrLite::SearchParams.new("callnumber_norm_ss:[#{norm_from} TO #{norm_to}]")
    if norm_from == norm_to
      cn_regex = "/" + StringUtils.solr_safe_regex(norm_from) + ".*/"
      params.q = "callnumber_norm_ss:#{cn_regex}"
    end

    page = 0
    while true
      page += 1
      params.page = page
      params.page_size = 1000
      params.sort = "callnumber_norm_ss asc"
      params.fl = ["*"]
      response = solr.search(params)
      Rails.logger.info("process_by_range: (#{norm_from}, #{norm_to}). Page: #{page}/#{response.num_pages}")
      yield response.solr_docs
      if (page * params.page_size) > response.num_found
        break
      end
    end
  end

  private
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
