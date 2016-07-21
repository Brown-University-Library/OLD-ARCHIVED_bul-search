namespace :josiah do
  desc "Populate Locations table with default list"
  task init_locations: :environment do
    if Location.all.count > 0
      abort "Cannot continue because the Location table already has data."
    end
    puts "Creating default locations..."
    default_locations.each do |location|
      Location.create(location)
    end
    puts "#{Location.count} locations created."
  end
end


def default_locations
  locations = []
  locations << {code: "9brow", name: "Brown University"}
  locations << {code: "9heln", name: "HELIN"}
  locations << {code: "a0001", name: "ARTSLIDE"}
  locations << {code: "arc", name: "HAY ARCHIVES"}
  locations << {code: "arccd", name: "HAY ARCHIVES CD"}
  locations << {code: "arccs", name: "HAY ARCHIVES CASSETTE"}
  locations << {code: "arcdv", name: "HAY ARCHIVES DVD"}
  locations << {code: "arcms", name: "HAY ARCHIVES MANUSCRIPTS"}
  locations << {code: "arcth", name: "HAY ARCHIVES THESES"}
  locations << {code: "bbbbb", name: "Borrow-Direct"}
  locations << {code: "bd", name: "Borrow-Direct"}
  locations << {code: "brown", name: "BROWN (exchange)"}
  locations << {code: "cass", name: "ROCK CASSETTE"}
  locations << {code: "chin", name: "ROCK CHINESE"}
  locations << {code: "chref", name: "ROCK CHINESE REF"}
  locations << {code: "cmicl", name: "ROCK CHINESE MICROFLM"}
  locations << {code: "cours", name: "COURSE RESERVE PROCESSING"}
  locations << {code: "eacg", name: "ROCK E-ASIAN GARDNER"}
  locations << {code: "eacr", name: "ROCK E-ASIAN REF"}
  locations << {code: "eacs", name: "ROCK E-ASIAN SERVICES"}
  locations << {code: "el001", name: "ONLINE"}
  locations << {code: "es", name: "ONLINE RESOURCE"}
  locations << {code: "es001", name: "ONLINE"}
  locations << {code: "esb", name: "ONLINE BOOK"}
  locations << {code: "esc", name: "ONLINE MAP"}
  locations << {code: "esd", name: "ONLINE DATABASE"}
  locations << {code: "esm", name: "ONLINE SCORE"}
  locations << {code: "ess", name: "ONLINE SERIAL"}
  locations << {code: "essr", name: "ONLINE SOUND RECORDING"}
  locations << {code: "esv", name: "ONLINE VIDEO"}
  locations << {code: "fffff", name: "ON THE FLY"}
  locations << {code: "g0001", name: "ORWIG"}
  locations << {code: "gar", name: "ROCK GARDNER"}
  locations << {code: "h0001", name: "HAY"}
  locations << {code: "h1793", name: "HAY 1793LIB"}
  locations << {code: "h2off", name: "HAY OFFSITE"}
  locations << {code: "h2qht", name: "HAY ANNEX TEMP"}
  locations << {code: "h2roc", name: "HAY at ROCK"}
  locations << {code: "hacq", name: "ACQ-DEPT HAY"}
  locations << {code: "haldr", name: "HAY ALDRICH"}
  locations << {code: "hamb", name: "HAY ANNMARY"}
  locations << {code: "hames", name: "HAY AMES"}
  locations << {code: "haskb", name: "HAY MILITARY"}
  locations << {code: "hawk", name: "HAY HAWKINS"}
  locations << {code: "haysr", name: "HAY SOUNDREC"}
  locations << {code: "hbapt", name: "HAY BAPTIST"}
  locations << {code: "hbd", name: "HAY BROADSIDES"}
  locations << {code: "hbian", name: "HAY BIANCHI"}
  locations << {code: "hblak", name: "HAY BLAKE"}
  locations << {code: "hbrys", name: "HAY BRYSON"}
  locations << {code: "hbuch", name: "HAY BUCHAN"}
  locations << {code: "hcd", name: "HAY CD"}
  locations << {code: "hchur", name: "HAY CHURCH"}
  locations << {code: "hcm", name: "HAY COM-FILE"}
  locations << {code: "hcr", name: "HAY COURSE RESERVES"}
  locations << {code: "hcs", name: "HAY CASSETTE"}
  locations << {code: "hcush", name: "HAY CUSHMAN"}
  locations << {code: "hdant", name: "HAY DANTE"}
  locations << {code: "hdhun", name: "HAY D.HUNTER"}
  locations << {code: "hdo", name: "HAY OCCULT"}
  locations << {code: "hdorr", name: "HAY DORR"}
  locations << {code: "hdpf", name: "HAY DUPEE FIREWORKS"}
  locations << {code: "hdpm", name: "HAY DUPEE MEXICANA"}
  locations << {code: "hdrow", name: "HAY DROWNE"}
  locations << {code: "hdv", name: "HAY DVD"}
  locations << {code: "heber", name: "HAY EBERSTDT"}
  locations << {code: "hfell", name: "HAY FELLS"}
  locations << {code: "hfly", name: "HAY (TEMPORARY)"}
  locations << {code: "hfost", name: "HAY FOSTER"}
  locations << {code: "hgorh", name: "HAY GORHAM"}
  locations << {code: "hh", name: "HAY HARRIS"}
  locations << {code: "hhbd", name: "HAY HARRIS BROADSIDES"}
  locations << {code: "hhcd", name: "HAY HARRIS CD"}
  locations << {code: "hhcm", name: "HAY HARRIS COM-FILE"}
  locations << {code: "hhcs", name: "HAY HARRIS CASSETTE"}
  locations << {code: "hhdv", name: "HAY HARRIS DVD"}
  locations << {code: "hhmcf", name: "HAY HARRIS MICROFLM"}
  locations << {code: "hhmch", name: "HAY HARRIS MICROFCH"}
  locations << {code: "hhr", name: "HAY HARRIS RARE"}
  locations << {code: "hhrf", name: "HAY HARRIS REF"}
  locations << {code: "hhrsm", name: "HAY HARRIS RARE-SM"}
  locations << {code: "hhsl", name: "HAY HARRIS SLIDES"}
  locations << {code: "hhsm", name: "HAY HARRIS SMALL"}
  locations << {code: "hhsr", name: "HAY HARRIS SOUNDREC"}
  locations << {code: "hhvd", name: "HAY HARRIS VIDEO"}
  locations << {code: "hjh", name: "HAY JOHN-HAY"}
  locations << {code: "hjhp", name: "HAY JOHN-HAY PERSONAL"}
  locations << {code: "hjlar", name: "HAY JAMES LAUGHLIN RARE"}
  locations << {code: "hjlau", name: "HAY JAMES LAUGHLIN"}
  locations << {code: "hkimb", name: "HAY KIMBALL"}
  locations << {code: "hkobd", name: "HAY KOOPMAN BROADSIDES"}
  locations << {code: "hkoop", name: "HAY KOOPMAN"}
  locations << {code: "hkz", name: "HAY KATZOFF"}
  locations << {code: "hkzvd", name: "HAY KATZOFF VIDEO"}
  locations << {code: "hlamo", name: "HAY LAMONT"}
  locations << {code: "hlibd", name: "HAY LINCOLN BROADSIDES"}
  locations << {code: "hlinc", name: "HAY LINCOLN"}
  locations << {code: "hlinl", name: "HAY LINCOLN LIBRARY"}
  locations << {code: "hlinm", name: "HAY LINCOLN MCLELLAN"}
  locations << {code: "hlirf", name: "HAY LINCOLN REF"}
  locations << {code: "hlowc", name: "HAY LOWNES"}
  locations << {code: "hlowt", name: "HAY LOWNES THOREAU"}
  locations << {code: "hmap", name: "HAY MAPS"}
  locations << {code: "hmcf", name: "HAY MICROFLM"}
  locations << {code: "hmch", name: "HAY MICROFCH"}
  locations << {code: "hmetc", name: "HAY METCALF"}
  locations << {code: "hmigu", name: "HAY MIGUEIS"}
  locations << {code: "hmill", name: "HAY MILLER"}
  locations << {code: "hmp", name: "HAY M-PICT"}
  locations << {code: "hmps", name: "HAY MAPS"}
  locations << {code: "hms", name: "HAY MANUSCRIPTS"}
  locations << {code: "hnap", name: "HAY NAPOLEON"}
  locations << {code: "hork", name: "HAY ORKNEY"}
  locations << {code: "hping", name: "HAY PINGREE"}
  locations << {code: "hpo", name: "HAY POSTERS"}
  locations << {code: "hpr", name: "HAY PRINTS"}
  locations << {code: "hrare", name: "HAY RARE"}
  locations << {code: "hreit", name: "HAY REITMAN"}
  locations << {code: "hrf", name: "HAY REF"}
  locations << {code: "hribd", name: "HAY RIDER BROADSIDES"}
  locations << {code: "hride", name: "HAY RIDER"}
  locations << {code: "hrim", name: "HAY RIMS"}
  locations << {code: "hrimd", name: "HAY RIMS DAVENPT"}
  locations << {code: "hsakl", name: "HAY SAKLAD"}
  locations << {code: "hscih", name: "HAY HIST-SCI"}
  locations << {code: "hscot", name: "HAY SCOTT"}
  locations << {code: "hshaw", name: "HAY SHAW"}
  locations << {code: "hshm", name: "HAY SHEET-MUSIC"}
  locations << {code: "hsilv", name: "HAY R.SILVER"}
  locations << {code: "hsl", name: "HAY SLIDES"}
  locations << {code: "hsmal", name: "HAY SMALL"}
  locations << {code: "hsmdv", name: "HAY SMITH DVD"}
  locations << {code: "hsmi", name: "HAY SMITH"}
  locations << {code: "hsmr", name: "HAY SMITH RARE"}
  locations << {code: "hsmsr", name: "HAY SMITH SOUNDREC"}
  locations << {code: "hsmvd", name: "HAY SMITH VIDEO"}
  locations << {code: "hsnel", name: "HAY SNELL"}
  locations << {code: "hstar", name: "HAY STAR"}
  locations << {code: "hste", name: "HAY STEPHENS"}
  locations << {code: "hstm", name: "HAY ST-MARTIN"}
  locations << {code: "hstrf", name: "HAY STAMP REF"}
  locations << {code: "ht", name: "HAY TRANSFER"}
  locations << {code: "htink", name: "HAY TINKER"}
  locations << {code: "htinr", name: "HAY TINKER RARE"}
  locations << {code: "hum", name: "ROCK HUM-RR"}
  locations << {code: "hvd", name: "HAY VIDEO"}
  locations << {code: "hward", name: "HAY WARD"}
  locations << {code: "hwarp", name: "HAY WARD PERSONAL"}
  locations << {code: "hwell", name: "HAY WELLS"}
  locations << {code: "hwhal", name: "HAY WHALING"}
  locations << {code: "hwhea", name: "HAY WHEATON"}
  locations << {code: "hwil", name: "HAY WILLIS R-R"}
  locations << {code: "hwj", name: "HAY WAND-JEW"}
  locations << {code: "hwt", name: "HAY WM-TABLE"}
  locations << {code: "j0001", name: "JCB"}
  locations << {code: "japan", name: "ROCK JAPANESE"}
  locations << {code: "jaref", name: "ROCK JAPANESE REF"}
  locations << {code: "jcb", name: "JCB"}
  locations << {code: "jcbbd", name: "JCB BROADSIDES"}
  locations << {code: "jcbmf", name: "JCB MAP FACSIMILE"}
  locations << {code: "jcbmp", name: "JCB MAP"}
  locations << {code: "jcbms", name: "JCB MANUSCRIPTS"}
  locations << {code: "jcbrf", name: "JCB REF"}
  locations << {code: "jcbsr", name: "JCB SERIALS"}
  locations << {code: "jcbvm", name: "JCB VISUAL MATERIALS"}
  locations << {code: "jmap", name: "ROCK JAPANESE MAPS"}
  locations << {code: "jot", name: "IN-PROCESS"}
  locations << {code: "korea", name: "ROCK KOREAN"}
  locations << {code: "koref", name: "ROCK KOREAN REF"}
  locations << {code: "m0001", name: "MEDIA"}
  locations << {code: "mdcr", name: "SCI MEDIA RESRV"}
  locations << {code: "mdcrq", name: "SCI MEDIA RESRV EQPT"}
  locations << {code: "mdmed", name: "SCI MEDIA"}
  locations << {code: "mdvid", name: "SCI MEDIA VIDEO"}
  locations << {code: "nnnnn", name: "IN-PROCESS"}
  locations << {code: "oacq", name: "ACQ-DEPT ORWIG"}
  locations << {code: "ocd", name: "ORWIG CD"}
  locations << {code: "ocm", name: "ORWIG COM-FILE"}
  locations << {code: "ocr", name: "ORWIG RESRV"}
  locations << {code: "ocrcd", name: "ORWIG RESRV-CD"}
  locations << {code: "ocrcs", name: "ORWIG RESRV-C"}
  locations << {code: "ocrdv", name: "ORWIG RESRV-DVD"}
  locations << {code: "ocreq", name: "ORWIG RESRV EQPT"}
  locations << {code: "ocrrm", name: "ORWIG RESRV-R"}
  locations << {code: "ocrsr", name: "ORWIG RESRV-LP"}
  locations << {code: "ocrvd", name: "ORWIG RESRV-V"}
  locations << {code: "ocs", name: "ORWIG CASSETTE"}
  locations << {code: "odv", name: "ORWIG DVD"}
  locations << {code: "ofly", name: "ORWIG (TEMPORARY)"}
  locations << {code: "okcd", name: "ORWIG ETHNO CD"}
  locations << {code: "okcs", name: "ORWIG ETHNO CASSETTE"}
  locations << {code: "okdv", name: "ORWIG ETHNO DVD"}
  locations << {code: "okrm", name: "ORWIG ETHNO CD-ROM"}
  locations << {code: "oksr", name: "ORWIG ETHNO SOUNDREC"}
  locations << {code: "okvd", name: "ORWIG ETHNO VIDEO"}
  locations << {code: "omcf", name: "ORWIG MICROFLM"}
  locations << {code: "omch", name: "ORWIG MICROFCH"}
  locations << {code: "omich", name: "ORWIG MICROFCH"}
  locations << {code: "omicl", name: "ORWIG MICROFLM"}
  locations << {code: "oncd", name: "ORWIG NEIMAN CD"}
  locations << {code: "onsr", name: "ORWIG NEIMAN SOUNDREC"}
  locations << {code: "onvd", name: "ORWIG NEIMAN VIDEO"}
  locations << {code: "oreel", name: "ORWIG REEL"}
  locations << {code: "orf", name: "ORWIG REF"}
  locations << {code: "orm", name: "ORWIG CD-ROM"}
  locations << {code: "orwig", name: "ORWIG"}
  locations << {code: "osec", name: "ORWIG SECURED"}
  locations << {code: "osr", name: "ORWIG SOUNDREC"}
  locations << {code: "ostor", name: "ORWIG STORAGE"}
  locations << {code: "ovd", name: "ORWIG VIDEO"}
  locations << {code: "p0001", name: "IN-PROCESS"}
  locations << {code: "q0001", name: "STORAGE"}
  locations << {code: "qacq", name: "ACQ-DEPT ANNEX"}
  locations << {code: "qh001", name: "STORAGE"}
  locations << {code: "qhroc", name: "ROCK"}
  locations << {code: "qhs", name: "ANNEX HAY"}
  locations << {code: "qhsci", name: "SCI"}
  locations << {code: "qhx", name: "STORAGE (HAY INTERIM)"}
  locations << {code: "qhz", name: "ANNEX HAY"}
  locations << {code: "qjcb", name: "ANNEX JCB (TEMP)"}
  locations << {code: "qs", name: "ANNEX"}
  locations << {code: "qsr", name: "ANNEX RESTRICTED"}
  locations << {code: "qx", name: "STORAGE (INTERIM)"}
  locations << {code: "qz", name: "ANNEX"}
  locations << {code: "r0001", name: "ROCK"}
  locations << {code: "racq", name: "ACQ-DEPT ROCK"}
  locations << {code: "raq", name: "ROCK ACQ-DEPT"}
  locations << {code: "rca", name: "ROCK CAT-DEPT"}
  locations << {code: "rcom", name: "ROCK COM-FILE"}
  locations << {code: "rcr", name: "ROCK RESRV"}
  locations << {code: "rcrq", name: "ROCK RESRV EQPT"}
  locations << {code: "rcut", name: "ROCK STORAGE CUTTER"}
  locations << {code: "rcutk", name: "ROCK CUTTER-K"}
  locations << {code: "rdiv", name: "ROCK DIVERSIONS"}
  locations << {code: "rdo", name: "ROCK DOC-REF"}
  locations << {code: "rdv", name: "ROCK DVD"}
  locations << {code: "rfar", name: "ROCK STORAGE FARMINGTON"}
  locations << {code: "rfinn", name: "ROCK FINN-ROOM"}
  locations << {code: "rfly", name: "ROCK (TEMPORARY)"}
  locations << {code: "rmap", name: "ROCK MAPS"}
  locations << {code: "rmcd", name: "ROCK STORAGE MICROCRD"}
  locations << {code: "rmcf", name: "ROCK MICROFLM"}
  locations << {code: "rmich", name: "ROCK MICROFCH"}
  locations << {code: "rmici", name: "ROCK MICROIND"}
  locations << {code: "rmicl", name: "ROCK MICROFLM"}
  locations << {code: "rmicp", name: "ROCK STORAGE MICROPRT"}
  locations << {code: "rock", name: "ROCK"}
  locations << {code: "rockr", name: "ROCK (RESTRICTED CIRC)"}
  locations << {code: "rra16", name: "ROCK ROOM A16"}
  locations << {code: "rrcom", name: "ROCK REF COM-FILE"}
  locations << {code: "rrd", name: "ROCK REF-DESK"}
  locations << {code: "rrec", name: "ROCK RECENT"}
  locations << {code: "rref", name: "ROCK REF"}
  locations << {code: "rrom", name: "ROCK REF-DESK CD-ROM"}
  locations << {code: "rse", name: "ROCK SERIALS"}
  locations << {code: "rsmch", name: "ROCK STORAGE MICROFCH"}
  locations << {code: "rsmcp", name: "ROCK STORAGE MICROPRT"}
  locations << {code: "rsmdd", name: "ROCK STORAGE DVD"}
  locations << {code: "rsmdv", name: "ROCK STORAGE VIDEO"}
  locations << {code: "rstar", name: "ROCK STORAGE STAR"}
  locations << {code: "rtex", name: "ROCK STORAGE TEXTBOOKS"}
  locations << {code: "rth", name: "ROCK STORAGE THESES"}
  locations << {code: "s0001", name: "SCI"}
  locations << {code: "sacq", name: "ACQ-DEPT SCI"}
  locations << {code: "sci", name: "SCI"}
  locations << {code: "scom", name: "SCI COM-FILE"}
  locations << {code: "scr", name: "SCI RESRV"}
  locations << {code: "scrq", name: "SCI RESRV EQPT"}
  locations << {code: "sdv", name: "SCI DVD"}
  locations << {code: "sfdv", name: "SCI FRIEDMAN DVD"}
  locations << {code: "sflrm", name: "SCI FRIEDMAN LANG-CD-ROM"}
  locations << {code: "sflvd", name: "SCI FRIEDMAN LANG-VIDEO"}
  locations << {code: "sfly", name: "SCI (TEMPORARY)"}
  locations << {code: "sldv", name: "SCI LANGUAGE DVD"}
  locations << {code: "smap", name: "SCI MAPS"}
  locations << {code: "smcf", name: "SCI MICROFLM"}
  locations << {code: "smich", name: "SCI MICROFCH"}
  locations << {code: "srcom", name: "SCI REF COM-FILE"}
  locations << {code: "srd", name: "SCI SERVICE DESK"}
  locations << {code: "sref", name: "SCI REF"}
  locations << {code: "srmed", name: "SCI REF MEDICAL"}
  locations << {code: "srrom", name: "SCI REF-DESK CD-ROM"}
  locations << {code: "sth", name: "SCI THESES"}
  locations << {code: "stor", name: "ROCK STORAGE"}
  locations << {code: "vc", name: "Virtual Catalog"}
  locations << {code: "vvvvv", name: "Virtual Catalog"}
  locations << {code: "xdoc", name: "ROCK DOCS"}
  locations << {code: "xfch", name: "ROCK STORAGE DOC-MFCH"}
  locations << {code: "xrom", name: "ROCK STORAGE DOC-CDROM"}
  locations << {code: "xxxxx", name: "RESERVES"}
  locations << {code: "xzd", name: "ROCK SSDS"}
  locations << {code: "y0001", name: "LANG RESOURCE CENTER"}
  locations << {code: "ycas", name: "LANG RES CTR CASSETTE"}
  locations << {code: "ycr", name: "LANG RES CTR RESRV"}
  locations << {code: "ycrq", name: "LANG RES CTR EQPT"}
  locations << {code: "ydvd", name: "LANG RES CTR DVD"}
  locations << {code: "yfly", name: "LANG RES CTR (TEMPORARY)"}
  locations << {code: "ylrc", name: "LANG RES CTR"}
  locations << {code: "yrom", name: "LANG RES CTR CD-ROM"}
  locations << {code: "yvid", name: "LANG RES CTR VIDEO"}
  locations << {code: "zd", name: "ROCK SSDS"}
  locations << {code: "zdcom", name: "ROCK SSDS COM-FILE"}
  locations << {code: "zzzzz", name: "Obsolete Location"}
end
