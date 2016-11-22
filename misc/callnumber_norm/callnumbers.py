import os
import re
import pymysql.cursors # see https://github.com/PyMySQL/PyMySQL

# ORIGINAL CODE by Ted Lawless starts here
__version__ = '0.1.0'

joiner = ''
topspace = ' '
bottomspace = '~'
topdigit = '0'
bottomdigit = '9'
weird_re = re.compile(r'^\s*[A-Z]+\s*\d+\.\d+\.\d+')
lccn_re = re.compile(r'''^
         \s*
        (?:VIDEO-D)? # for video stuff
        (?:DVD-ROM)? # DVDs, obviously
        (?:CD-ROM)?  # CDs
        (?:TAPE-C)?  # Tapes
        (?:1-SIZE)? #Brown specific
        (?:3-SIZE)?
        (?:RIVER)?
        (?:BOX)?
        (?:2-SIZE)?
        (?:SMALL BOX)? #end Brown specific
        \s*
        ([A-Z]{1,3})  # alpha
        \s*
        (?:         # optional numbers with optional decimal point
          (\d+)
          (?:\s*?\.\s*?(\d+))?
        )?
        \s*
        (?:               # optional cutter
          \.? \s*
          ([A-Z])      # cutter letter
          \s*
          (\d+ | \Z)        # cutter numbers
        )?
        \s*
        (?:               # optional cutter
          \.? \s*
          ([A-Z])      # cutter letter
          \s*
          (\d+ | \Z)        # cutter numbers
        )?
        \s*
        (?:               # optional cutter
          \.? \s*
          ([A-Z])      # cutter letter
          \s*
          (\d+ | \Z)        # cutter numbers
        )?
        (\s+.+?)?        # everthing else
        \s*$
        ''', re.VERBOSE)

def check_value(value, space):
  """Replacement for the if else logic not available in Python 2.4"""
  if value:
    return value
  else:
    return space


def normalize(lc, bottom=False):
    lc = lc.upper()
    bottomout = bottom

    if re.match(weird_re, lc):
        return None

    m = re.match(lccn_re, lc)
    if not m:
        return None

    origs = m.groups('')
    (alpha, num, dec, c1alpha, c1num,
     c2alpha, c2num, c3alpha, c3num, extra) = origs

    if (len(dec) > 2):
        return None

    if alpha and not (num or dec or c1alpha or c1num or c2alpha \
                          or c2num or c3alpha or c3num):
        if extra:
            return None
        if bottomout:
            return alpha + bottomspace * (3 - len(alpha))
        return alpha

    enorm = re.sub(r'[^A-Z0-9]', '', extra)
    num = '%04d' % int(num)

    topnorm = [
        alpha + topspace * (3 - len(alpha)),
        num + topdigit * (4 - len(num)),
        dec + topdigit * (2 - len(dec)),
        #c1alpha if c1alpha else topspace,
        #(topspace, c1alpha)[c1alpha],
        check_value(c1alpha, topspace),
        c1num + topdigit * (3 - len(c1num)),
        #c2alpha if c2alpha else topspace,
        #(topspace, c2alpha)[c2alpha],
        check_value(c2alpha, topspace),
        c2num + topdigit * (3 - len(c2num)),
        #c3alpha if c3alpha else topspace,
        #(topspace, c3alpha)[c3alpha],
        check_value(c3alpha, topspace),
        c3num + topdigit * (3 - len(c3num)),
        ' ' + enorm,
    ]

    bottomnorm = [
        alpha + bottomspace * (3 - len(alpha)),
        num + bottomdigit * (4 - len(num)),
        dec + bottomdigit * (2 - len(dec)),
        #c1alpha if c1alpha else bottomspace,
        #(bottomspace, c1alpha)[c1alpha],
        check_value(c1alpha, bottomspace),
        c1num + bottomdigit * (3 - len(c1num)),
        #c2alpha if c2alpha else bottomspace,
        #(bottomspace, c2alpha)[c2alpha],
        check_value(c2alpha, bottomspace),
        c2num + bottomdigit * (3 - len(c2num)),
        #c3alpha if c3alpha else bottomspace,
        #(bottomspace, c3alpha)[c3alpha],
        check_value(c3alpha, bottomspace),
        c3num + bottomdigit * (3 - len(c3num)),
        ' ' + enorm,
    ]

    if extra:
        return joiner.join(topnorm)

    topnorm.pop()
    bottomnorm.pop()

    inds = range(1, 9)
    inds.reverse()
    for i in inds:
        end = topnorm.pop()
        if origs[i]:
            if bottomout:
                end = joiner.join(bottomnorm[i:])
            return joiner.join(topnorm) + joiner + end


class LC(object):

    def __init__(self, callno):
        try:
            self.denormalized = callno.upper()
        except AttributeError:
            print "*** ERROR: '%s' not a string?" % (callno)
        self.normalized = normalize(callno)

    def __unicode__(self):
        return self.normalized

    def __str__(self):
        return self.normalized

    @property
    def range_start(self):
        return self.normalized

    @property
    def range_end(self):
        return normalize(self.denormalized, True)

    def components(self, include_blanks=False):
        if re.match(weird_re, self.denormalized):
            return None

        m = re.match(lccn_re, self.denormalized)
        if not m:
            return None

        (alpha, num, dec, c1alpha, c1num, c2alpha, c2num,
         c3alpha, c3num, extra) = m.groups('')

        if dec:
            num += '.%s' % dec

        c1 = ''.join((c1alpha, c1num))
        c2 = ''.join((c2alpha, c2num))
        c3 = ''.join((c3alpha, c3num))

        if re.search(r'\S', c1):
            c1 = '.%s' % c1

        comps = []
        for comp in (alpha, num, c1, c2, c3, extra):
            if not re.search(r'\S', comp) and not include_blanks:
                continue
            comp = re.match(r'^\s*(.*?)\s*$', comp).group(1)
            comps.append(comp)
        return comps

# ORIGINAL CODE by Ted Lawless ends here


# Below is the code that I added to process all the records in
# the `callnumbers` table that have not been normalized.
def save_batch(cnx, batch):
    sql_update = "UPDATE callnumbers SET normalized=%s WHERE id=%s"
    cursor = cnx.cursor()
    for (id, normalized) in batch:
        update_data = (normalized, id)
        cursor.execute(sql_update, update_data)
    cnx.commit()


def normalize_next_batch(cnx):
    cursor = cnx.cursor()
    query = ("SELECT id, original FROM callnumbers "
             "WHERE normalized is NULL "
             "ORDER BY id "
             "LIMIT 20000")

    batch = []
    cursor.execute(query)
    while True:
        row = cursor.fetchone()
        if row == None:
            break
        id = row["id"]
        original = row["original"]
        try:
            norm = normalize(original)
            if norm is None:
                norm = "NONE"
        except ValueError:
            norm = "ERR"
        batch.append((id, norm))

    cursor.close()
    return batch


def test_db(cnx):
    cursor = cnx.cursor()
    cursor.execute("SELECT 1")
    row = cursor.fetchone()
    print row


def normalize_all_pending(cnx):
    batch_count = 0
    while True:
        batch_count += 1
        print "Processing batch " + str(batch_count) + "..."
        batch = normalize_next_batch(cnx)
        if len(batch) == 0:
            # we are done - no more records to normalize were found.
            break
        else:
            save_batch(cnx, batch)


db_info = {
    "user": os.environ.get("DB_USR", "root"),
    "password": os.environ.get("DB_PASS", ""),
    "host": os.environ.get("DB_HOST", "127.0.0.1"),
    "database": os.environ.get("DB_NAME", "bul_search_dev"),
    "cursorclass": pymysql.cursors.DictCursor
}
connStringDisplay = "{0}@{1}/{2}".format(db_info["user"], db_info["host"], db_info["database"])
print "Connecting to " + connStringDisplay
cnx = pymysql.connect(**db_info)

# test_db(cnx)
normalize_all_pending(cnx)

cnx.close()
print "Done!"
