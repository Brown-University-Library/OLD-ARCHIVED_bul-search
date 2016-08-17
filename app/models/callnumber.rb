class Callnumber < ActiveRecord::Base

  def self.nearby_ids(bib_id)
    callnumber = Callnumber.find_by_bib(bib_id)
    return [] if callnumber == nil

    # items on the shelf _before_ this bib_id
    sql = <<-END_SQL
      select bib
      from callnumbers
      where normalized < "#{callnumber.normalized}"
      order by normalized desc
      limit 10;
    END_SQL
    before_rows = ActiveRecord::Base.connection.execute(sql)
    before_ids = []
    before_rows.each do |r|
      before_ids << r["bib"]
    end

    # items on the shelf _after_ this bib_id
    sql = <<-END_SQL.gsub(/\n/, '')
      select bib
      from callnumbers
      where normalized > "#{callnumber.normalized}"
      order by normalized limit 10;
    END_SQL
    after_rows = ActiveRecord::Base.connection.execute(sql)

    byebug
    ids = before_ids.reverse()
    ids << bib_id
    after_rows.each do |r|
      ids << r["bib"]
    end
    ids
  end

  def self.find_bib_id(callnumber)
    record = Callnumber.find_by_original(callnumber)
    record == nil ? nil : record.bib
  end

  # Calculates the normalized call number for a given call number.
  #
  # Notice that we store the normalized version along with the
  # BIB record id so that we can fetch the individual BIB record
  # from Solr regardless of the call number. This is needed because
  # call numbers are stored in more than one format (e.g. the
  # availability service includes the 1-SIZE token but we don't
  # store them like that in Millennium or in Solr). Having the BIB
  # record ID allows us to find the correct BIB record in Solr
  # without any extra guessing.
  def self.normalize_one(bib_id, callnumber)
    record = Callnumber.find_by_original(callnumber)
    if record == nil || record.normalized == nil
      record = Callnumber.new
      record.original = callnumber
      record.bib = bib_id
      record.normalized = CallnumberNormalizer.normalize_one(callnumber)
      record.save!
    else
      # already normalized
    end
  end

  # Returns the Library of Congress Class and Subclass
  # for a given callnumber. For example:
  #
  # a, b = loc_class("AB133 .M56 2016")
  # => ["AB", "AB133"]
  def self.loc_class(callnumber)
    matches = /(\d\d\d\d\s*)*(\d\-SIZE\s*)*([A-Z]*)([\d]*)/.match(callnumber)
    year = matches[1] # ignore
    size = matches[2] # ignore
    lc_class = matches[3]
    lc_subclass = matches[3] + matches[4]
    [lc_class, lc_subclass]
  end
end

# General notes on call numbers:
#
# 050 is LOC call number
# 090 is our LOC call number
#
# Other schemes are in other fields,
# for example, we use 091 for non-LOC
# call numbers.
#
# For the browse feature we should prefer
# 050 over 091.
#
#
# Sometimes we have a call number in field 945a
# (when we have call number in the item record)
#
#
#
#
# Beyond words by McFerrin, Bobby (M1366.M238 B49x 2002)
# M1366.M238    -> M1366.M0238
# M1366.M24     -> M1366.M024
#
# These two are the same
# M1366 .A398x 2000z
# M1366.A398x 2000z
#   Cutter number: .A398x
#
#
# M1366 .398x 2000z
# M1366.398x 2000z
#
# Ordering
# M1366.M238 B49x 2002
# M1366.N123 B49x 2002
# M1366 .Z398x 2000z
