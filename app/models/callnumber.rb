class Callnumber
  attr_reader :lc_class, :lc_subclass, :callnumber

  def initialize(callnumber)
    @callnumber = callnumber || ""
    parse()
  end

  private
    def parse()
      matches = /(\d\d\d\d\s*)*(\d\-SIZE\s*)*([A-Z]*)([\d]*)/.match(@callnumber)
      year = matches[1] # ignore
      size = matches[2] # ignore
      @lc_class = matches[3]
      @lc_subclass = matches[3] + matches[4]
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
