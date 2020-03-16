# Methods to browse through call numbers.
# This class should be renamed to CallnumberBrowse
class Callnumber < ActiveRecord::Base

  # Number of books on the shelf to show before/after the current book.
  NEARBY_BATCH_SIZE = 5

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

  # Returns an array of BIB record IDs with call numbers
  # that are in the call number range provided.
  def self.get_by_range(cn_from, cn_to)
    sql = <<-END_SQL.gsub(/\n/, '')
      select bib, normalized, original
      from callnumbers
      where normalized >= "#{cn_from}" and normalized <= "#{cn_to}"
      order by normalized asc
    END_SQL
    rows = ActiveRecord::Base.connection.exec_query(sql).rows
    bibs = rows.map do |r|
      {id: r[0], normalized: r[1], original: r[2]}
    end
    return bibs
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
