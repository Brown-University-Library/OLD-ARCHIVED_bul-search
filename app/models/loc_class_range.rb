class LocClassRange

  def find_ranges(code)
    ranges.select {|r| code >= r[:begin] && code <= r[:end] }
  end

  def find_range(code)
    find_ranges(code).last
  end

  def find_index(code)
    index = -1
    ranges.each_with_index do |r, i|
      if code >= r[:begin] && code <= r[:end]
        index = i
      end
    end
    index
  end

  def find_previous(code)
    index = find_index(code)
    return nil if index <= 0
    ranges[index-1]
  end

  def find_next(code)
    index = find_index(code)
    return nil if index < 0
    ranges[index+1]
  end

  def ranges
    @ranges ||= hard_coded_ranges()
  end

  def hard_coded_ranges
    r = []
    r << {:begin=>"B1", :end=>"B5802", :text=>"Philosophy (General)"}
    r << {:begin=>"B69", :end=>"B99", :text=>"General works"}
    r << {:begin=>"B108", :end=>"B5802", :text=>"By period"}
    r << {:begin=>"B108", :end=>"B708", :text=>"Ancient"}
    r << {:begin=>"B720", :end=>"B765", :text=>"Medieval"}
    r << {:begin=>"B770", :end=>"B785", :text=>"Renaissance"}
    r << {:begin=>"B790", :end=>"B5802", :text=>"Modern"}
    r << {:begin=>"B808", :end=>"B849", :text=>"Special topics and schools of philosophy"}
    r << {:begin=>"B850", :end=>"B5739", :text=>"By region or country"}
    r << {:begin=>"B5800", :end=>"B5802", :text=>"By religion"}
    r << {:begin=>"BC1", :end=>"BC199", :text=>"Logic"}
    r << {:begin=>"BC11", :end=>"BC39", :text=>"History"}
    r << {:begin=>"BC25", :end=>"BC39", :text=>"By period"}
    r << {:begin=>"BC60", :end=>"BC99", :text=>"General works"}
    r << {:begin=>"BC171", :end=>"BC199", :text=>"Special topics"}
    r << {:begin=>"BD10", :end=>"BD701", :text=>"Speculative philosophy"}
    r << {:begin=>"BD10", :end=>"BD41", :text=>"General philosophical works"}
    r << {:begin=>"BD95", :end=>"BD131", :text=>"Metaphysics"}
    r << {:begin=>"BD143", :end=>"BD237", :text=>"Epistemology. Theory of knowledge"}
    r << {:begin=>"BD240", :end=>"BD260", :text=>"Methodology"}
    r << {:begin=>"BD300", :end=>"BD450", :text=>"Ontology"}
    r << {:begin=>"BD493", :end=>"BD701", :text=>"Cosmology"}
    r << {:begin=>"BF1", :end=>"BF990", :text=>"Psychology"}
    r << {:begin=>"BF38", :end=>"BF64", :text=>"Philosophy. Relation to other topics"}
    r << {:begin=>"BF173", :end=>"BF175.5", :text=>"Psychoanalysis"}
    r << {:begin=>"BF176", :end=>"BF176.5", :text=>"Psychological tests and testing"}
    r << {:begin=>"BF180", :end=>"BF198.7", :text=>"Experimental psychology"}
    r << {:begin=>"BF203", :end=>"BF203", :text=>"Gestalt psychology"}
    r << {:begin=>"BF207", :end=>"BF209", :text=>"Psychotropic drugs and other substances"}
    r << {:begin=>"BF231", :end=>"BF299", :text=>"Sensation. Aesthesiology"}
    r << {:begin=>"BF309", :end=>"BF499", :text=>"Consciousness. Cognition"}
    r << {:begin=>"BF501", :end=>"BF505", :text=>"Motivation"}
    r << {:begin=>"BF511", :end=>"BF593", :text=>"Affection. Feeling. Emotion"}
    r << {:begin=>"BF608", :end=>"BF635", :text=>"Will. Volition. Choice. Control"}
    r << {:begin=>"BF636", :end=>"BF637", :text=>"Applied psychology"}
    r << {:begin=>"BF638", :end=>"BF648", :text=>"New Thought. Menticulture, etc."}
    r << {:begin=>"BF660", :end=>"BF685", :text=>"Comparative psychology. Animal and human psychology"}
    r << {:begin=>"BF692", :end=>"BF692.5", :text=>"Psychology of sex. Sexual behavior"}
    r << {:begin=>"BF697", :end=>"BF697.5", :text=>"Differential psychology. Individuality. Self"}
    r << {:begin=>"BF698", :end=>"BF698.9", :text=>"Personality"}
    r << {:begin=>"BF699", :end=>"BF711", :text=>"Genetic psychology"}
    r << {:begin=>"BF712", :end=>"BF724.85", :text=>"Developmental psychology"}
    r << {:begin=>"BF725", :end=>"BF727", :text=>"Class psychology"}
    r << {:begin=>"BF795", :end=>"BF839", :text=>"Temperament. Character"}
    r << {:begin=>"BF839.8", :end=>"BF885", :text=>"Physiognomy. Phrenology"}
    r << {:begin=>"BF889", :end=>"BF905", :text=>"Graphology. Study of handwriting"}
    r << {:begin=>"BF908", :end=>"BF940", :text=>"The hand. Palmistry"}
    r << {:begin=>"BF1001", :end=>"BF1389", :text=>"Parapsychology"}
    r << {:begin=>"BF1001", :end=>"BF1045", :text=>"Psychic research. Psychology of the conscious"}
    r << {:begin=>"BF1048", :end=>"BF1108", :text=>"Hallucinations. Sleep. Dreaming. Visions"}
    r << {:begin=>"BF1111", :end=>"BF1156", :text=>"Hypnotism. Suggestion. Mesmerism. Subliminal projection"}
    r << {:begin=>"BF1161", :end=>"BF1171", :text=>"Telepathy. Mind reading. Thought transference"}
    r << {:begin=>"BF1228", :end=>"BF1389", :text=>"Spiritualism"}
    r << {:begin=>"BF1404", :end=>"BF2055", :text=>"Occult sciences"}
    r << {:begin=>"BF1444", :end=>"BF1486", :text=>"Ghosts. Apparitions. Hauntings"}
    r << {:begin=>"BF1501", :end=>"BF1562", :text=>"Demonology. Satanism. Possession"}
    r << {:begin=>"BF1562.5", :end=>"BF1584", :text=>"Witchcraft"}
    r << {:begin=>"BF1585", :end=>"BF1623", :text=>"Magic. Hermetics. Necromancy"}
    r << {:begin=>"BF1651", :end=>"BF1729", :text=>"Astrology"}
    r << {:begin=>"BF1745", :end=>"BF1779", :text=>"Oracles. Sibyls. Divinations"}
    r << {:begin=>"BF1783", :end=>"BF1815", :text=>"Seers. Prophets. Prophecies"}
    r << {:begin=>"BF1845", :end=>"BF1891", :text=>"Fortune-telling"}
    r << {:begin=>"BF2050", :end=>"BF2055", :text=>"Human-alien encounters. Contact between humans and"}
    r << {:begin=>"BH1", :end=>"BH301", :text=>"Aesthetics"}
    r << {:begin=>"BH81", :end=>"BH208", :text=>"History"}
    r << {:begin=>"BH301", :end=>"BH301", :text=>"Special topics"}
    r << {:begin=>"BJ1", :end=>"BJ1725", :text=>"Ethics"}
    r << {:begin=>"BJ71", :end=>"BJ1185", :text=>"History and general works"}
    r << {:begin=>"BJ1188", :end=>"BJ1295", :text=>"Religious ethics"}
    r << {:begin=>"BJ1298", :end=>"BJ1335", :text=>"Evolutionary and genetic ethics"}
    r << {:begin=>"BJ1365", :end=>"BJ1385", :text=>"Positivist ethics"}
    r << {:begin=>"BJ1388", :end=>"BJ1388", :text=>"Socialist ethics"}
    r << {:begin=>"BJ1390", :end=>"BJ1390.5", :text=>"Communist ethics"}
    r << {:begin=>"BJ1392", :end=>"BJ1392", :text=>"Totalitarian ethics"}
    r << {:begin=>"BJ1395", :end=>"BJ1395", :text=>"Feminist ethics"}
    r << {:begin=>"BJ1518", :end=>"BJ1697", :text=>"Individual ethics. Character. Virtue"}
    r << {:begin=>"BJ1725", :end=>"BJ1725", :text=>"Ethics of social groups, classes, etc. Professional ethics"}
    r << {:begin=>"BJ1801", :end=>"BJ2195", :text=>"Social usages. Etiquette"}
    r << {:begin=>"BJ2021", :end=>"BJ2078", :text=>"Etiquette of entertaining"}
    r << {:begin=>"BJ2139", :end=>"BJ2156", :text=>"Etiquette of travel"}
    r << {:begin=>"BJ2195", :end=>"BJ2195", :text=>"Telephone etiquette"}
    r << {:begin=>"BL1", :end=>"BL2790", :text=>"Religions. Mythology. Rationalism"}
    r << {:begin=>"BL1", :end=>"BL50", :text=>"Religion (General)"}
    r << {:begin=>"BL51", :end=>"BL65", :text=>"Philosophy of religion. Psychology of religion. Religion"}
    r << {:begin=>"BL70", :end=>"BL71", :text=>"Sacred books (General)"}
    r << {:begin=>"BL71.5", :end=>"BL73", :text=>"Biography"}
    r << {:begin=>"BL74", :end=>"BL99", :text=>"Religions of the world"}
    r << {:begin=>"BL175", :end=>"BL265", :text=>"Natural theology"}
    r << {:begin=>"BL175", :end=>"BL190", :text=>"General"}
    r << {:begin=>"BL200", :end=>"BL200", :text=>"Theism"}
    r << {:begin=>"BL205", :end=>"BL216", :text=>"Nature and attributes of Deity"}
    r << {:begin=>"BL217", :end=>"BL217", :text=>"Polytheism"}
    r << {:begin=>"BL218", :end=>"BL218", :text=>"Dualism"}
    r << {:begin=>"BL220", :end=>"BL220", :text=>"Pantheism"}
    r << {:begin=>"BL221", :end=>"BL221", :text=>"Monotheism"}
    r << {:begin=>"BL224", :end=>"BL227", :text=>"Creation. Theory of the earth"}
    r << {:begin=>"BL239", :end=>"BL265", :text=>"Religion and science"}
    r << {:begin=>"BL270", :end=>"BL270", :text=>"Unity and plurality"}
    r << {:begin=>"BL290", :end=>"BL290", :text=>"The soul"}
    r << {:begin=>"BL300", :end=>"BL325", :text=>"The myth. Comparative mythology"}
    r << {:begin=>"BL350", :end=>"BL385", :text=>"Classification of religions"}
    r << {:begin=>"BL410", :end=>"BL410", :text=>"Religions in relation to one another"}
    r << {:begin=>"BL425", :end=>"BL490", :text=>"Religious doctrines (General)"}
    r << {:begin=>"BL430", :end=>"BL430", :text=>"Origins of religion"}
    r << {:begin=>"BL435", :end=>"BL457", :text=>"Nature worship"}
    r << {:begin=>"BL458", :end=>"BL458", :text=>"Women in comparative religion"}
    r << {:begin=>"BL460", :end=>"BL460", :text=>"Sex worship. Phallicism"}
    r << {:begin=>"BL465", :end=>"BL470", :text=>"Worship of human beings"}
    r << {:begin=>"BL473", :end=>"BL490", :text=>"Other"}
    r << {:begin=>"BL500", :end=>"BL547", :text=>"Eschatology"}
    r << {:begin=>"BL550", :end=>"BL619", :text=>"Worship. Cultus"}
    r << {:begin=>"BL624", :end=>"BL629.5", :text=>"Religious life"}
    r << {:begin=>"BL630", :end=>"BL(632.5)", :text=>"Religious organization"}
    r << {:begin=>"BL660", :end=>"BL2680", :text=>"History and principles of religions"}
    r << {:begin=>"BL660", :end=>"BL660", :text=>"Indo-European. Aryan"}
    r << {:begin=>"BL685", :end=>"BL685", :text=>"Ural-Altaic"}
    r << {:begin=>"BL687", :end=>"BL687", :text=>"Mediterranean region"}
    r << {:begin=>"BL689", :end=>"BL980", :text=>"European. Occidental"}
    r << {:begin=>"BL700", :end=>"BL820", :text=>"Classical (Etruscan, Greek, Roman)"}
    r << {:begin=>"BL830", :end=>"BL875", :text=>"Germanic and Norse"}
    r << {:begin=>"BL900", :end=>"BL980", :text=>"Other European"}
    r << {:begin=>"BL1000", :end=>"BL2370", :text=>"Asian. Oriental"}
    r << {:begin=>"BL1000", :end=>"BL1035", :text=>"General"}
    r << {:begin=>"BL1050", :end=>"BL1050", :text=>"Northern and Central Asia"}
    r << {:begin=>"BL1055", :end=>"BL1055", :text=>"Southern and Eastern Asia"}
    r << {:begin=>"BL1060", :end=>"BL1060", :text=>"Southwestern Asia. Asia Minor. Levant"}
    r << {:begin=>"BL1100", :end=>"BL1295", :text=>"Hinduism"}
    r << {:begin=>"BL1100", :end=>"BL1107.5", :text=>"General"}
    r << {:begin=>"BL1108.2", :end=>"BL1108.7", :text=>"Religious education"}
    r << {:begin=>"BL1109.2", :end=>"BL1109.7", :text=>"Antiquities. Archaeology. Inscriptions"}
    r << {:begin=>"BL1111", :end=>"BL1143.2", :text=>"Sacred books. Sources"}
    r << {:begin=>"BL1112.2", :end=>"BL1137.5", :text=>"Vedic texts"}
    r << {:begin=>"BL1140.2", :end=>"BL1140.4", :text=>"Pur?as"}
    r << {:begin=>"BL1141.2", :end=>"BL1142.6", :text=>"Tantric texts"}
    r << {:begin=>"BL1145", :end=>"BL1146", :text=>"Hindu literature"}
    r << {:begin=>"BL1153.7", :end=>"BL1168", :text=>"By region or country"}
    r << {:begin=>"BL1212.32", :end=>"BL1215", :text=>"Doctrines. Theology"}
    r << {:begin=>"BL1216", :end=>"BL1225", :text=>"Hindu pantheon. Deities"}
    r << {:begin=>"BL1225.2", :end=>"BL1243.58", :text=>"Religious life"}
    r << {:begin=>"BL1243.72", :end=>"BL1243.78", :text=>"Monasteries. Temples, etc."}
    r << {:begin=>"BL1271.2", :end=>"BL1295", :text=>"Modifications. Sects"}
    r << {:begin=>"BL1284.5", :end=>"BL1289.592", :text=>"Vaishnavism"}
    r << {:begin=>"BL1300", :end=>"BL1380", :text=>"Jainism"}
    r << {:begin=>"BL1310", :end=>"BL1314.2", :text=>"Sacred books. Sources"}
    r << {:begin=>"BL1315", :end=>"BL1317", :text=>"Jain literature"}
    r << {:begin=>"BL1375.3", :end=>"BL1375.7", :text=>"Jaina pantheon. Deities"}
    r << {:begin=>"BL1376", :end=>"BL1378.85", :text=>"Forms of worship"}
    r << {:begin=>"BL1379", :end=>"BL1380", :text=>"Modifications, etc."}
    r << {:begin=>"BL1500", :end=>"BL1590", :text=>"Zoroastrianism (Mazdeism). Parseeism"}
    r << {:begin=>"BL1595", :end=>"BL1595", :text=>"Yezidis"}
    r << {:begin=>"BL1600", :end=>"BL1695", :text=>"Semitic religions"}
    r << {:begin=>"BL1600", :end=>"BL1605", :text=>"General"}
    r << {:begin=>"BL1610", :end=>"BL1610", :text=>"Aramean"}
    r << {:begin=>"BL1615", :end=>"BL1616", :text=>"Sumerian"}
    r << {:begin=>"BL1620", :end=>"BL1625", :text=>"Assyro-Babylonian"}
    r << {:begin=>"BL1630", :end=>"BL1630", :text=>"Chaldean"}
    r << {:begin=>"BL1635", :end=>"BL1635", :text=>"Harranian. Pseudo-Sabian"}
    r << {:begin=>"BL1640", :end=>"BL1645", :text=>"Syrian. Palestinian. Samaritan"}
    r << {:begin=>"BL1650", :end=>"BL1650", :text=>"Hebrew"}
    r << {:begin=>"BL1660", :end=>"BL1665", :text=>"Phoenician. Carthaginian, etc."}
    r << {:begin=>"BL1670", :end=>"BL1672", :text=>"Canaanite"}
    r << {:begin=>"BL1675", :end=>"BL1675", :text=>"Moabite. Philistine"}
    r << {:begin=>"BL1680", :end=>"BL1685", :text=>"Arabian (except Islam)"}
    r << {:begin=>"BL1695", :end=>"BL1695", :text=>"Druses"}
    r << {:begin=>"BL1710", :end=>"BL1710", :text=>"Ethiopian"}
    r << {:begin=>"BL1750", :end=>"BL2350", :text=>"By region or country"}
    r << {:begin=>"BL1790", :end=>"BL1975", :text=>"China"}
    r << {:begin=>"BL1830", :end=>"BL1883", :text=>"Confucianism"}
    r << {:begin=>"BL1899", :end=>"BL1942.85", :text=>"Taoism"}
    r << {:begin=>"BL2000", :end=>"BL2032", :text=>"India"}
    r << {:begin=>"BL2017", :end=>"BL2018.7", :text=>"Sikhism"}
    r << {:begin=>"BL2195", :end=>"BL2228", :text=>"Japan"}
    r << {:begin=>"BL2216", :end=>"BL2227.8", :text=>"Shinto"}
    r << {:begin=>"BL2230", :end=>"BL2240", :text=>"Korea"}
    r << {:begin=>"BL2390", :end=>"BL2490", :text=>"African"}
    r << {:begin=>"BL2420", :end=>"BL2460", :text=>"Egyptian"}
    r << {:begin=>"BL2500", :end=>"BL2592", :text=>"American"}
    r << {:begin=>"BL2600", :end=>"BL2630", :text=>"Pacific Ocean islands. Oceania"}
    r << {:begin=>"BL2670", :end=>"BL2670", :text=>"Arctic regions"}
    r << {:begin=>"BL2700", :end=>"BL2790", :text=>"Rationalism"}
    r << {:begin=>"BM1", :end=>"BM990", :text=>"Judaism"}
    r << {:begin=>"BM1", :end=>"BM449", :text=>"General"}
    r << {:begin=>"BM70", :end=>"BM135", :text=>"Study and teaching"}
    r << {:begin=>"BM150", :end=>"BM449", :text=>"History"}
    r << {:begin=>"BM201", :end=>"BM449", :text=>"By region or country"}
    r << {:begin=>"BM480", :end=>"BM488.8", :text=>"Pre-Talmudic Jewish literature (non-Biblical)"}
    r << {:begin=>"BM495", :end=>"BM532", :text=>"Sources of Jewish religion. Rabbinical literature"}
    r << {:begin=>"BM497", :end=>"BM509", :text=>"Talmudic literature"}
    r << {:begin=>"BM497", :end=>"BM497.8", :text=>"Mishnah"}
    r << {:begin=>"BM498", :end=>"BM498.8", :text=>"Palestinian Talmud"}
    r << {:begin=>"BM499", :end=>"BM504.7", :text=>"Babylonian Talmud"}
    r << {:begin=>"BM507", :end=>"BM507.5", :text=>"Baraita"}
    r << {:begin=>"BM508", :end=>"BM508.5", :text=>"Tosefta"}
    r << {:begin=>"BM510", :end=>"BM518", :text=>"Midrash"}
    r << {:begin=>"BM520", :end=>"BM523.7", :text=>"Halacha"}
    r << {:begin=>"BM525", :end=>"BM526", :text=>"Cabala"}
    r << {:begin=>"BM529", :end=>"BM529", :text=>"Jewish tradition"}
    r << {:begin=>"BM534", :end=>"BM538", :text=>"Relation of Judaism to special subject fields"}
    r << {:begin=>"BM534", :end=>"BM536", :text=>"Religions"}
    r << {:begin=>"BM545", :end=>"BM582", :text=>"Principles of Judaism (General)"}
    r << {:begin=>"BM585", :end=>"BM585.4", :text=>"Controversial works against the Jews"}
    r << {:begin=>"BM590", :end=>"BM591", :text=>"Jewish works against Christianity and Islam"}
    r << {:begin=>"BM600", :end=>"BM645", :text=>"Dogmatic Judaism"}
    r << {:begin=>"BM646", :end=>"BM646", :text=>"Heresy, heresies"}
    r << {:begin=>"BM648", :end=>"BM648", :text=>"Apologetics"}
    r << {:begin=>"BM650", :end=>"BM747", :text=>"Practical Judaism"}
    r << {:begin=>"BM651", :end=>"BM652.7", :text=>"Priests, rabbis, etc."}
    r << {:begin=>"BM653", :end=>"BM653.7", :text=>"Congregations. Synagogues"}
    r << {:begin=>"BM654", :end=>"BM655.6", :text=>"The tabernacle. The temple"}
    r << {:begin=>"BM656", :end=>"BM657", :text=>"Forms of worship"}
    r << {:begin=>"BM660", :end=>"BM679", :text=>"Liturgy and ritual"}
    r << {:begin=>"BM690", :end=>"BM695", :text=>"Festivals and fasts"}
    r << {:begin=>"BM700", :end=>"BM720", :text=>"Rites and customs"}
    r << {:begin=>"BM723", :end=>"BM729", :text=>"Jewish way of life. Spiritual life. Mysticism. Personal"}
    r << {:begin=>"BM730", :end=>"BM747", :text=>"Preaching. Homiletics"}
    r << {:begin=>"BM750", :end=>"BM755", :text=>"Biography"}
    r << {:begin=>"BM900", :end=>"BM990", :text=>"Samaritans"}
    r << {:begin=>"BP1", :end=>"BP610", :text=>"Islam. Bahai Faith. Theosophy, etc."}
    r << {:begin=>"BP1", :end=>"BP253", :text=>"Islam"}
    r << {:begin=>"BP1", :end=>"BP68", :text=>"General"}
    r << {:begin=>"BP42", :end=>"BP48", :text=>"Study and teaching"}
    r << {:begin=>"BP50", :end=>"BP68", :text=>"History"}
    r << {:begin=>"BP70", :end=>"BP80", :text=>"Biography"}
    r << {:begin=>"BP75", :end=>"BP77.75", :text=>"Muammad, Prophet, d. 632"}
    r << {:begin=>"BP87", :end=>"BP89", :text=>"Islamic literature"}
    r << {:begin=>"BP100", :end=>"BP(157)", :text=>"Sacred books"}
    r << {:begin=>"BP100", :end=>"BP134", :text=>"Koran"}
    r << {:begin=>"BP128.15", :end=>"BP129.83", :text=>"Special parts and chapters"}
    r << {:begin=>"BP130", :end=>"BP134", :text=>"Works about the Koran"}
    r << {:begin=>"BP135", :end=>"BP136.9", :text=>"Hadith literature. Traditions. Sunna"}
    r << {:begin=>"BP137", :end=>"BP137.5", :text=>"Koranic and other Islamic legends"}
    r << {:begin=>"BP160", :end=>"BP165", :text=>"General works on Islam"}
    r << {:begin=>"BP165.5", :end=>"BP165.5", :text=>"Dogma (Aq?(id)"}
    r << {:begin=>"BP166", :end=>"BP166.94", :text=>"Theology (Kal?m)"}
    r << {:begin=>"BP167.5", :end=>"BP167.5", :text=>"Heresy, heresies, heretics"}
    r << {:begin=>"BP168", :end=>"BP168", :text=>"Apostasy from Islam"}
    r << {:begin=>"BP169", :end=>"BP169", :text=>"Works against Islam and the Koran"}
    r << {:begin=>"BP170", :end=>"BP170", :text=>"Works in defense of Islam. Islamic apologetics"}
    r << {:begin=>"BP170.2", :end=>"BP170.2", :text=>"Benevolent work. Social work. Welfare work, etc."}
    r << {:begin=>"BP170.3", :end=>"BP170.5", :text=>"Missionary work of Islam"}
    r << {:begin=>"BP171", :end=>"BP173", :text=>"Relation of Islam to other religions"}
    r << {:begin=>"BP173.25", :end=>"BP173.45", :text=>"Islamic sociology"}
    r << {:begin=>"BP174", :end=>"BP190", :text=>"The practice of Islam"}
    r << {:begin=>"BP176", :end=>"BP181", :text=>"The five duties of a Moslem. Pillars of Islam"}
    r << {:begin=>"BP182", :end=>"BP182", :text=>"Jihad (Holy War)"}
    r << {:begin=>"BP184", :end=>"BP184.9", :text=>"Religious ceremonies, rites, etc."}
    r << {:begin=>"BP186", :end=>"BP186.97", :text=>"Special days and seasons, fasts, feasts,"}
    r << {:begin=>"BP187", :end=>"BP187.9", :text=>"Shrines, sacred places, etc."}
    r << {:begin=>"BP188", :end=>"BP190", :text=>"Islamic religious life"}
    r << {:begin=>"BP188.2", :end=>"BP188.3", :text=>"Devotional literature"}
    r << {:begin=>"BP188.45", :end=>"BP189.65", :text=>"Sufism. Mysticism. Dervishes"}
    r << {:begin=>"BP189.68", :end=>"BP189.7", :text=>"Monasticism"}
    r << {:begin=>"BP191", :end=>"BP253", :text=>"Branches, sects, etc."}
    r << {:begin=>"BP192", :end=>"BP194.9", :text=>"Shiites"}
    r << {:begin=>"BP221", :end=>"BP223", :text=>"Black Muslims"}
    r << {:begin=>"BP232", :end=>"BP232", :text=>"Moorish Science Temple of America"}
    r << {:begin=>"BP251", :end=>"BP253", :text=>"Nurculuk"}
    r << {:begin=>"BP300", :end=>"BP395", :text=>"Bahai Faith"}
    r << {:begin=>"BP500", :end=>"BP585", :text=>"Theosophy"}
    r << {:begin=>"BP595", :end=>"BP597", :text=>"Anthroposophy"}
    r << {:begin=>"BP600", :end=>"BP610", :text=>"Other beliefs and movements"}
    r << {:begin=>"BQ1", :end=>"BQ9800", :text=>"Buddhism"}
    r << {:begin=>"BQ1", :end=>"BQ10", :text=>"Periodicals. Yearbooks (General)"}
    r << {:begin=>"BQ12", :end=>"BQ93", :text=>"Societies, councils, associations, clubs, etc."}
    r << {:begin=>"BQ96", :end=>"BQ99", :text=>"Financial institutions. Trusts"}
    r << {:begin=>"BQ100", :end=>"BQ102", :text=>"Congresses. Conferences (General)"}
    r << {:begin=>"BQ104", :end=>"BQ105", :text=>"Directories (General)"}
    r << {:begin=>"BQ107", :end=>"BQ109", :text=>"Museums. Exhibitions"}
    r << {:begin=>"BQ115", :end=>"BQ126", :text=>"General collections. Collected works"}
    r << {:begin=>"BQ128", :end=>"BQ128", :text=>"Encyclopedias (General)"}
    r << {:begin=>"BQ130", :end=>"BQ130", :text=>"Dictionaries (General)"}
    r << {:begin=>"BQ133", :end=>"BQ133", :text=>"Terminology"}
    r << {:begin=>"BQ135", :end=>"BQ135", :text=>"Questions and answers. Maxims (General)"}
    r << {:begin=>"BQ141", :end=>"BQ209", :text=>"Religious education (General)"}
    r << {:begin=>"BQ210", :end=>"BQ219", :text=>"Research"}
    r << {:begin=>"BQ221", :end=>"BQ249", :text=>"Antiquities. Archaeology"}
    r << {:begin=>"BQ240", :end=>"BQ244", :text=>"Literary discoveries"}
    r << {:begin=>"BQ246", :end=>"BQ249", :text=>"Inscriptions, etc."}
    r << {:begin=>"BQ251", :end=>"BQ799", :text=>"History"}
    r << {:begin=>"BQ800", :end=>"BQ829", :text=>"Persecutions"}
    r << {:begin=>"BQ840", :end=>"BQ999", :text=>"Biography"}
    r << {:begin=>"BQ840", :end=>"BQ858", :text=>"Collective"}
    r << {:begin=>"BQ860", :end=>"BQ999", :text=>"Individual"}
    r << {:begin=>"BQ860", :end=>"BQ939", :text=>"Gautama Buddha"}
    r << {:begin=>"BQ940", :end=>"BQ999", :text=>"Other"}
    r << {:begin=>"BQ1001", :end=>"BQ1045", :text=>"Buddhist literature"}
    r << {:begin=>"BQ1100", :end=>"BQ3340", :text=>"Tripiaka (Canonical literature)"}
    r << {:begin=>"BQ4000", :end=>"BQ4060", :text=>"General works"}
    r << {:begin=>"BQ4061", :end=>"BQ4570", :text=>"Doctrinal and systematic Buddhism"}
    r << {:begin=>"BQ4180", :end=>"BQ4565", :text=>"Special doctrines"}
    r << {:begin=>"BQ4570", :end=>"BQ4570", :text=>"Special topics and relations to special subjects"}
    r << {:begin=>"BQ4600", :end=>"BQ4610", :text=>"Relation to other religious and philosophical systems"}
    r << {:begin=>"BQ4620", :end=>"BQ4905", :text=>"Buddhist pantheon"}
    r << {:begin=>"BQ4911", :end=>"BQ5720", :text=>"Practice of Buddhism. Forms of worship"}
    r << {:begin=>"BQ4965", :end=>"BQ5030", :text=>"Ceremonies and rites. Ceremonial rules"}
    r << {:begin=>"BQ5035", :end=>"BQ5065", :text=>"Hymns. Chants. Recitations"}
    r << {:begin=>"BQ5070", :end=>"BQ5075", :text=>"Altar, liturgical objects, ornaments, memorials, etc."}
    r << {:begin=>"BQ5080", :end=>"BQ5085", :text=>"Vestments, altar cloths, etc."}
    r << {:begin=>"BQ5090", :end=>"BQ5095", :text=>"Liturgical functions"}
    r << {:begin=>"BQ5100", :end=>"BQ5125", :text=>"Symbols and symbolism"}
    r << {:begin=>"BQ5130", :end=>"BQ5137", :text=>"Temple. Temple organization"}
    r << {:begin=>"BQ5140", :end=>"BQ5355", :text=>"Buddhist ministry. Priesthood. Organization"}
    r << {:begin=>"BQ5251", :end=>"BQ5305", :text=>"Education and training"}
    r << {:begin=>"BQ5310", :end=>"BQ5350", :text=>"Preaching"}
    r << {:begin=>"BQ5360", :end=>"BQ5680", :text=>"Religious life"}
    r << {:begin=>"BQ5485", :end=>"BQ5530", :text=>"Precepts for laymen"}
    r << {:begin=>"BQ5535", :end=>"BQ5594", :text=>"Devotional literature. Meditations. Prayers"}
    r << {:begin=>"BQ5595", :end=>"BQ5633", :text=>"Devotion. Meditation. Prayer"}
    r << {:begin=>"BQ5635", :end=>"BQ5675", :text=>"Spiritual life. Mysticism. Englightenment. Perfection"}
    r << {:begin=>"BQ5700", :end=>"BQ5720", :text=>"Festivals. Days and seasons"}
    r << {:begin=>"BQ5725", :end=>"BQ5845", :text=>"Folklore"}
    r << {:begin=>"BQ5821", :end=>"BQ5845", :text=>"Miracle literature"}
    r << {:begin=>"BQ5851", :end=>"BQ5899", :text=>"Benevolent work. Social work. Welfare work, etc."}
    r << {:begin=>"BQ5901", :end=>"BQ5975", :text=>"Missionary work"}
    r << {:begin=>"BQ6001", :end=>"BQ6160", :text=>"Monasticism and monastic life Sagha (Order)"}
    r << {:begin=>"BQ6200", :end=>"BQ6240", :text=>"Asceticism. Hermits. Wayfaring life"}
    r << {:begin=>"BQ6300", :end=>"BQ6388", :text=>"Monasteries. Temples. Shrines. Sites"}
    r << {:begin=>"BQ6400", :end=>"BQ6495", :text=>"Pilgrims and pilgrimages"}
    r << {:begin=>"BQ7001", :end=>"BQ9800", :text=>"Modifications, schools, etc."}
    r << {:begin=>"BQ7100", :end=>"BQ7285", :text=>"Therav?da (Hinayana) Buddhism"}
    r << {:begin=>"BQ7300", :end=>"BQ7529", :text=>"Mahayana Buddhism"}
    r << {:begin=>"BQ7530", :end=>"BQ7950", :text=>"Tibetan Buddhism (Lamaism)"}
    r << {:begin=>"BQ7960", :end=>"BQ7989", :text=>"Bonpo (Sect)"}
    r << {:begin=>"BQ8000", :end=>"BQ9800", :text=>"Special modifications, sects, etc."}
    r << {:begin=>"BQ8500", :end=>"BQ8769", :text=>"Pure Land Buddhism"}
    r << {:begin=>"BQ8900", :end=>"BQ9099", :text=>"Tantric Buddhism"}
    r << {:begin=>"BQ9250", :end=>"BQ9519", :text=>"Zen Buddhism"}
    r << {:begin=>"BR1", :end=>"BR1725", :text=>"Christianity"}
    r << {:begin=>"BR60", :end=>"BR67", :text=>"Early Christian literature. Fathers of the Church, etc."}
    r << {:begin=>"BR115", :end=>"BR115", :text=>"Christianity in relation to special subjects"}
    r << {:begin=>"BR130", :end=>"BR133.5", :text=>"Christian antiquities. Archaeology. Museums"}
    r << {:begin=>"BR140", :end=>"BR1510", :text=>"History"}
    r << {:begin=>"BR160", :end=>"BR481", :text=>"By period"}
    r << {:begin=>"BR160", :end=>"BR275", :text=>"Early and medieval"}
    r << {:begin=>"BR280", :end=>"BR280", :text=>"Renaissance. Renaissance and Reformation"}
    r << {:begin=>"BR290", :end=>"BR481", :text=>"Modern period"}
    r << {:begin=>"BR323.5", :end=>"BR334.2", :text=>"Luther, Martin"}
    r << {:begin=>"BR500", :end=>"BR1510", :text=>"By region or country"}
    r << {:begin=>"BR1600", :end=>"BR1609", :text=>"Persecution. Martyrs"}
    r << {:begin=>"BR1609.5", :end=>"BR1609.5", :text=>"Dissent"}
    r << {:begin=>"BR1610", :end=>"BR1610", :text=>"Tolerance and toleration"}
    r << {:begin=>"BR1615", :end=>"BR1617", :text=>"Liberalism"}
    r << {:begin=>"BR1620", :end=>"BR1620", :text=>"Sacrilege (History)"}
    r << {:begin=>"BR1690", :end=>"BR1725", :text=>"Biography"}
    r << {:begin=>"BS1", :end=>"BS2970", :text=>"The Bible"}
    r << {:begin=>"BS11", :end=>"BS115", :text=>"Early versions"}
    r << {:begin=>"BS125", :end=>"BS355", :text=>"Modern texts and versions"}
    r << {:begin=>"BS125", :end=>"BS198", :text=>"English"}
    r << {:begin=>"BS199", :end=>"BS313", :text=>"Other European languages"}
    r << {:begin=>"BS315", :end=>"BS355", :text=>"Non-European languages"}
    r << {:begin=>"BS315", :end=>"BS315", :text=>"Asian languages"}
    r << {:begin=>"BS325", :end=>"BS325", :text=>"African languages"}
    r << {:begin=>"BS335", :end=>"BS335", :text=>"Languages of Oceania and Australasia"}
    r << {:begin=>"BS345", :end=>"BS345", :text=>"American Indian languages"}
    r << {:begin=>"BS350", :end=>"BS350", :text=>"Mixed languages"}
    r << {:begin=>"BS355", :end=>"BS355", :text=>"Artificial languages"}
    r << {:begin=>"BS410", :end=>"BS680", :text=>"Works about the Bible"}
    r << {:begin=>"BS500", :end=>"BS534.8", :text=>"Criticism and interpretation"}
    r << {:begin=>"BS535", :end=>"BS537", :text=>"The Bible as literature"}
    r << {:begin=>"BS546", :end=>"BS558", :text=>"Bible stories. Paraphrases of Bible stories. The Bible story"}
    r << {:begin=>"BS569", :end=>"BS580", :text=>"Men, women, and children of the Bible"}
    r << {:begin=>"BS580", :end=>"BS580", :text=>"Individual Old Testament characters"}
    r << {:begin=>"BS585", :end=>"BS613", :text=>"Study and teaching"}
    r << {:begin=>"BS647", :end=>"BS649", :text=>"Prophecy"}
    r << {:begin=>"BS650", :end=>"BS667", :text=>"Bible and science"}
    r << {:begin=>"BS670", :end=>"BS672", :text=>"Bible and social sciences"}
    r << {:begin=>"BS701", :end=>"BS1830", :text=>"Old Testament"}
    r << {:begin=>"BS705", :end=>"BS815", :text=>"Early versions"}
    r << {:begin=>"BS825", :end=>"BS1013", :text=>"Modern texts and versions"}
    r << {:begin=>"BS1091", :end=>"BS1099", :text=>"Selections. Quotations"}
    r << {:begin=>"BS1110", :end=>"BS1199", :text=>"Works about the Old Testament"}
    r << {:begin=>"BS1160", :end=>"BS1191.5", :text=>"Criticism and interpretation"}
    r << {:begin=>"BS1200", :end=>"BS1830", :text=>"Special parts of the Old Testament"}
    r << {:begin=>"BS1901", :end=>"BS2970", :text=>"New Testament"}
    r << {:begin=>"BS1937", :end=>"BS2020", :text=>"Early texts and versions"}
    r << {:begin=>"BS2025", :end=>"BS2213", :text=>"Modern texts and versions"}
    r << {:begin=>"BS2260", :end=>"BS2269", :text=>"Selections. Quotations"}
    r << {:begin=>"BS2280", :end=>"BS2545", :text=>"Works about the New Testament"}
    r << {:begin=>"BS2350", :end=>"BS2393", :text=>"Criticism and interpretation"}
    r << {:begin=>"BS2415", :end=>"BS2417", :text=>"The teachings of Jesus"}
    r << {:begin=>"BS2430", :end=>"BS2520", :text=>"Men, women, and children of the New Testament"}
    r << {:begin=>"BS2525", :end=>"BS2544", :text=>"Study and teaching"}
    r << {:begin=>"BS2547", :end=>"BS2970", :text=>"Special parts of the New Testament"}
    r << {:begin=>"BS2640", :end=>"BS2765.6", :text=>"Epistles of Paul"}
    r << {:begin=>"BT10", :end=>"BT1480", :text=>"Doctrinal Theology"}
    r << {:begin=>"BT19", :end=>"BT37", :text=>"Doctrine and dogma"}
    r << {:begin=>"BT93", :end=>"BT93.6", :text=>"Judaism"}
    r << {:begin=>"BT95", :end=>"BT97.2", :text=>"Divine law. Moral government"}
    r << {:begin=>"BT98", :end=>"BT180", :text=>"God"}
    r << {:begin=>"BT109", :end=>"BT115", :text=>"Doctrine of the Trinity"}
    r << {:begin=>"BT117", :end=>"BT123", :text=>"Holy Spirit. The Paraclete"}
    r << {:begin=>"BT126", :end=>"BT127.5", :text=>"Revelation"}
    r << {:begin=>"BT130", :end=>"BT153", :text=>"Divine attributes"}
    r << {:begin=>"BT198", :end=>"BT590", :text=>"Christology"}
    r << {:begin=>"BT296", :end=>"BT500", :text=>"Life of Christ"}
    r << {:begin=>"BT580", :end=>"BT580", :text=>"Miracles. Apparitions. Shrines, sanctuaries, images,"}
    r << {:begin=>"BT587", :end=>"BT587", :text=>"Relics"}
    r << {:begin=>"BT595", :end=>"BT680", :text=>"Mary, Mother of Jesus Christ. Mariology"}
    r << {:begin=>"BT650", :end=>"BT660", :text=>"Miracles. Apparitions. Shrines, sanctuaries, images,"}
    r << {:begin=>"BT695", :end=>"BT749", :text=>"Creation"}
    r << {:begin=>"BT750", :end=>"BT811", :text=>"Salvation. Soteriology"}
    r << {:begin=>"BT819", :end=>"BT891", :text=>"Eschatology. Last things"}
    r << {:begin=>"BT899", :end=>"BT940", :text=>"Future state. Future life"}
    r << {:begin=>"BT960", :end=>"BT985", :text=>"Invisible world (saints, demons, etc.)"}
    r << {:begin=>"BT990", :end=>"BT1010", :text=>"Creeds, confessions, covenants, etc."}
    r << {:begin=>"BT1029", :end=>"BT1040", :text=>"Catechisms"}
    r << {:begin=>"BT1095", :end=>"BT1255", :text=>"Apologetics. Evidences of Christianity"}
    r << {:begin=>"BT1313", :end=>"BT1480", :text=>"History of specific doctrines and movements. Heresies and schisms"}
    r << {:begin=>"BV1", :end=>"BV5099", :text=>"Practical Theology"}
    r << {:begin=>"BV5", :end=>"BV530", :text=>"Worship (Public and private)"}
    r << {:begin=>"BV30", :end=>"BV135", :text=>"Times and seasons. The Church year"}
    r << {:begin=>"BV43", :end=>"BV64", :text=>"Feast days"}
    r << {:begin=>"BV65", :end=>"BV70", :text=>"Saints( days"}
    r << {:begin=>"BV80", :end=>"BV105", :text=>"Fasts"}
    r << {:begin=>"BV107", :end=>"BV133", :text=>"Lord(s Day. Sunday. Sabbath"}
    r << {:begin=>"BV150", :end=>"BV168", :text=>"Christian symbols and symbolism"}
    r << {:begin=>"BV169", :end=>"BV199", :text=>"Liturgy and ritual"}
    r << {:begin=>"BV200", :end=>"BV200", :text=>"Family worship"}
    r << {:begin=>"BV205", :end=>"BV287", :text=>"Prayer"}
    r << {:begin=>"BV301", :end=>"BV530", :text=>"Hymnology"}
    r << {:begin=>"BV360", :end=>"BV465", :text=>"Denominational and special types of hymnbooks in English"}
    r << {:begin=>"BV467", :end=>"BV510", :text=>"Hymns in languages other than English"}
    r << {:begin=>"BV590", :end=>"BV1652", :text=>"Ecclesiastical theology"}
    r << {:begin=>"BV598", :end=>"BV603", :text=>"The Church"}
    r << {:begin=>"BV629", :end=>"BV631", :text=>"Church and state"}
    r << {:begin=>"BV637", :end=>"BV637.5", :text=>"City churches"}
    r << {:begin=>"BV638", :end=>"BV638.8", :text=>"The rural church. The church and country life"}
    r << {:begin=>"BV646", :end=>"BV651", :text=>"Church polity"}
    r << {:begin=>"BV652", :end=>"BV652.9", :text=>"Church management. Efficiency"}
    r << {:begin=>"BV652.95", :end=>"BV657", :text=>"Mass media and telecommunication in religion"}
    r << {:begin=>"BV659", :end=>"BV683", :text=>"Ministry. Clergy. Religious vocations"}
    r << {:begin=>"BV700", :end=>"BV707", :text=>"Parish. Congregation. The local church"}
    r << {:begin=>"BV770", :end=>"BV777", :text=>"Church finance. Church property"}
    r << {:begin=>"BV800", :end=>"BV873", :text=>"Sacraments. Ordinances"}
    r << {:begin=>"BV803", :end=>"BV814", :text=>"Baptism"}
    r << {:begin=>"BV823", :end=>"BV828", :text=>"Holy Communion. Lord(s Supper. Eucharist"}
    r << {:begin=>"BV835", :end=>"BV838", :text=>"Marriage"}
    r << {:begin=>"BV840", :end=>"BV850", :text=>"Penance"}
    r << {:begin=>"BV895", :end=>"BV896", :text=>"Shrines. Holy places"}
    r << {:begin=>"BV900", :end=>"BV1450", :text=>"Religious societies, associations, etc."}
    r << {:begin=>"BV950", :end=>"BV1280", :text=>"Religious societies of men, brotherhoods, etc."}
    r << {:begin=>"BV1000", :end=>"BV1220", :text=>"Young Men(s Christian Associations"}
    r << {:begin=>"BV1300", :end=>"BV1395", :text=>"Religious societies of women"}
    r << {:begin=>"BV1300", :end=>"BV1393", :text=>"Young Women(s Christian Associations"}
    r << {:begin=>"BV1460", :end=>"BV1615", :text=>"Religious education (General)"}
    r << {:begin=>"BV1620", :end=>"BV1652", :text=>"Social life, recreation, etc., in the church"}
    r << {:begin=>"BV2000", :end=>"BV3705", :text=>"Missions"}
    r << {:begin=>"BV2123", :end=>"BV2595", :text=>"Special churches"}
    r << {:begin=>"BV2130", :end=>"BV2300", :text=>"Roman Catholic Church"}
    r << {:begin=>"BV2350", :end=>"BV2595", :text=>"Protestant churches"}
    r << {:begin=>"BV2610", :end=>"BV2695", :text=>"Special types of missions"}
    r << {:begin=>"BV2750", :end=>"BV3695", :text=>"Missions in individual countries"}
    r << {:begin=>"BV3750", :end=>"BV3799", :text=>"Evangelism. Revivals"}
    r << {:begin=>"BV4000", :end=>"BV4470", :text=>"Pastoral theology"}
    r << {:begin=>"BV4019", :end=>"BV4180", :text=>"Education"}
    r << {:begin=>"BV4019", :end=>"BV4167", :text=>"Training for the ordained ministry"}
    r << {:begin=>"BV4168", :end=>"BV4180", :text=>"Training for lay workers"}
    r << {:begin=>"BV4200", :end=>"BV4317", :text=>"Preaching. Homiletics"}
    r << {:begin=>"BV4239", :end=>"BV4317", :text=>"Sermons"}
    r << {:begin=>"BV4390", :end=>"BV4399", :text=>"Personal life of the clergy"}
    r << {:begin=>"BV4400", :end=>"BV4470", :text=>"Practical church work. Social work. Work of the layman"}
    r << {:begin=>"BV4485", :end=>"BV5099", :text=>"Practical religion. The Christian life"}
    r << {:begin=>"BV4520", :end=>"BV4526.2", :text=>"Religious duties"}
    r << {:begin=>"BV4625", :end=>"BV4780", :text=>"Moral theology"}
    r << {:begin=>"BV4625", :end=>"BV4627", :text=>"Sins and vices"}
    r << {:begin=>"BV4630", :end=>"BV4647", :text=>"Virtues"}
    r << {:begin=>"BV4650", :end=>"BV4715", :text=>"Precepts from the Bible"}
    r << {:begin=>"BV4720", :end=>"BV4780", :text=>"Precepts of the Church. Commandments of the Church"}
    r << {:begin=>"BV4800", :end=>"BV4897", :text=>"Works of meditation and devotion"}
    r << {:begin=>"BV4900", :end=>"BV4911", :text=>"Works of consolation and cheer"}
    r << {:begin=>"BV4912", :end=>"BV4950", :text=>"Conversion literature"}
    r << {:begin=>"BV5015", :end=>"BV5068", :text=>"Asceticism"}
    r << {:begin=>"BV5070", :end=>"BV5095", :text=>"Mysticism"}
    r << {:begin=>"BV5099", :end=>"BV5099", :text=>"Quietism"}
    r << {:begin=>"BX1", :end=>"BX9999", :text=>"Christian Denominations"}
    r << {:begin=>"BX1", :end=>"BX9.5", :text=>"Church unity. Ecumenical movement. Interdenominational"}
    r << {:begin=>"BX100", :end=>"BX189", :text=>"Eastern churches. Oriental churches"}
    r << {:begin=>"BX100", :end=>"BX107", :text=>"General"}
    r << {:begin=>"BX120", :end=>"BX129", :text=>"Armenian Church"}
    r << {:begin=>"BX130", :end=>"BX139", :text=>"Coptic Church"}
    r << {:begin=>"BX140", :end=>"BX149", :text=>"Ethiopic or Abyssinian Church"}
    r << {:begin=>"BX150", :end=>"BX159", :text=>"Nestorian, Chaldean, or East Syrian Church"}
    r << {:begin=>"BX160", :end=>"BX169", :text=>"St. Thomas Christians. Malabar Christians. Mar Thoma Syrian"}
    r << {:begin=>"BX170", :end=>"BX179", :text=>"Syrian or Jacobite Church"}
    r << {:begin=>"BX180", :end=>"BX189", :text=>"Maronite Church"}
    r << {:begin=>"BX200", :end=>"BX756", :text=>"Orthodox Eastern Church"}
    r << {:begin=>"BX200", :end=>"BX395", :text=>"General"}
    r << {:begin=>"BX400", :end=>"BX756", :text=>"Divisions of the church"}
    r << {:begin=>"BX400", :end=>"BX440", :text=>"Patriarchates of the East. Melchites"}
    r << {:begin=>"BX450", :end=>"BX450.93", :text=>"Church of Cyprus"}
    r << {:begin=>"BX460", :end=>"BX605", :text=>"Russian Church"}
    r << {:begin=>"BX610", :end=>"BX620", :text=>"Church of Greece"}
    r << {:begin=>"BX630", :end=>"BX639", :text=>"Orthodox Church in Austria and Hungary"}
    r << {:begin=>"BX650", :end=>"BX659", :text=>"Bulgarian Church"}
    r << {:begin=>"BX660", :end=>"BX669", :text=>"Georgian Church"}
    r << {:begin=>"BX670", :end=>"BX679", :text=>"Montenegrin Church"}
    r << {:begin=>"BX690", :end=>"BX699", :text=>"Romanian Church"}
    r << {:begin=>"BX710", :end=>"BX719", :text=>"Serbian Church. Yugoslav Church"}
    r << {:begin=>"BX720", :end=>"BX729", :text=>"Orthodox Eastern Church, Macedonian"}
    r << {:begin=>"BX729.5", :end=>"BX729.5", :text=>"Orthodox Eastern Church, Ukrainian"}
    r << {:begin=>"BX729.9", :end=>"BX755", :text=>"Orthodox Church in other regions or countries"}
    r << {:begin=>"BX800", :end=>"BX4795", :text=>"Catholic Church"}
    r << {:begin=>"BX800", :end=>"BX839", :text=>"Periodicals. Societies, councils, congresses, etc."}
    r << {:begin=>"BX840", :end=>"BX840", :text=>"Museums. Exhibitions"}
    r << {:begin=>"BX841", :end=>"BX841", :text=>"Dictionaries. Encyclopedias"}
    r << {:begin=>"BX845", :end=>"BX845", :text=>"Directories. Yearbooks"}
    r << {:begin=>"BX847", :end=>"BX847", :text=>"Atlases"}
    r << {:begin=>"BX850", :end=>"BX875", :text=>"Documents"}
    r << {:begin=>"BX880", :end=>"BX891", :text=>"General collected works"}
    r << {:begin=>"BX895", :end=>"BX939", :text=>"Study and teaching"}
    r << {:begin=>"BX940", :end=>"BX1745", :text=>"History"}
    r << {:begin=>"BX1746", :end=>"BX1755", :text=>"Theology. Doctrine. Dogmatics"}
    r << {:begin=>"BX1756", :end=>"BX1756", :text=>"Sermons"}
    r << {:begin=>"BX1760", :end=>"BX1779.5", :text=>"Controversial works"}
    r << {:begin=>"BX1781", :end=>"BX1788", :text=>"Catholic Church and other churches"}
    r << {:begin=>"BX1790", :end=>"BX1793", :text=>"Catholic Church and the state"}
    r << {:begin=>"BX1800", :end=>"BX1920", :text=>"Government and organization"}
    r << {:begin=>"BX1958", :end=>"BX1968", :text=>"Creeds and catechisms"}
    r << {:begin=>"BX1969", :end=>"BX1969", :text=>"Forms of worship. Catholic practice"}
    r << {:begin=>"BX1970", :end=>"BX2175", :text=>"Liturgy and ritual"}
    r << {:begin=>"BX2050", :end=>"BX2175", :text=>"Prayers and devotions"}
    r << {:begin=>"BX2177", :end=>"BX2198", :text=>"Meditations. Devotional readings. Spiritual exercises, etc."}
    r << {:begin=>"BX2200", :end=>"BX2292", :text=>"Sacraments"}
    r << {:begin=>"BX2295", :end=>"BX2310", :text=>"Sacramentals"}
    r << {:begin=>"BX2312", :end=>"BX2312", :text=>"Images"}
    r << {:begin=>"BX2315", :end=>"BX2324", :text=>"Relics. Shrines. Pilgrimages. Processions"}
    r << {:begin=>"BX2325", :end=>"BX2333", :text=>"Saints. Hagiology"}
    r << {:begin=>"BX2347", :end=>"BX2377", :text=>"Practical religion. Christian life"}
    r << {:begin=>"BX2380", :end=>"BX2386", :text=>"Religious life. Religious state"}
    r << {:begin=>"BX2400", :end=>"BX4563", :text=>"Monasticism. Religious orders"}
    r << {:begin=>"BX2890", :end=>"BX4192", :text=>"Religious orders of men"}
    r << {:begin=>"BX4200", :end=>"BX4563", :text=>"Religious orders of women"}
    r << {:begin=>"BX4600", :end=>"BX4644", :text=>"Churches, cathedrals, abbeys (as parish churches), etc."}
    r << {:begin=>"BX4650", :end=>"BX4705", :text=>"Biography and portraits"}
    r << {:begin=>"BX4650", :end=>"BX4698", :text=>"Collective"}
    r << {:begin=>"BX4654", :end=>"BX4662", :text=>"Saints and martyrs"}
    r << {:begin=>"BX4700", :end=>"BX4705", :text=>"Individual"}
    r << {:begin=>"BX4700", :end=>"BX4700", :text=>"Saints"}
    r << {:begin=>"BX4710.1", :end=>"BX4715.95", :text=>"Eastern churches in communion with Rome. Catholics of the"}
    r << {:begin=>"BX4716.4", :end=>"BX4795", :text=>"Dissenting sects other than Protestant"}
    r << {:begin=>"BX4718.5", :end=>"BX4735", :text=>"Jansenists"}
    r << {:begin=>"BX4737", :end=>"BX4737", :text=>"French schisms of the 19th century"}
    r << {:begin=>"BX4740", :end=>"BX4740", :text=>"German Catholics"}
    r << {:begin=>"BX4751", :end=>"BX4793", :text=>"Old Catholics"}
    r << {:begin=>"BX4793.5", :end=>"BX4794.25", :text=>"Independent Catholic Churches"}
    r << {:begin=>"BX4795", :end=>"BX4795", :text=>"Other"}
    r << {:begin=>"BX4800", :end=>"BX9999", :text=>"Protestantism"}
    r << {:begin=>"BX4800", :end=>"BX4861", :text=>"General"}
    r << {:begin=>"BX4872", :end=>"BX4924", :text=>"Pre-Reformation"}
    r << {:begin=>"BX4872", :end=>"BX4893", :text=>"Waldenses and Albigenses"}
    r << {:begin=>"BX4900", :end=>"BX4906", :text=>"Lollards. Wycliffites"}
    r << {:begin=>"BX4913", :end=>"BX4924", :text=>"Hussites"}
    r << {:begin=>"BX4920", :end=>"BX4924", :text=>"Bohemian Brethren"}
    r << {:begin=>"BX4929", :end=>"BX4951", :text=>"Post-Reformation"}
    r << {:begin=>"BX4929", :end=>"BX4946", :text=>"Anabaptists"}
    r << {:begin=>"BX4950", :end=>"BX4951", :text=>"Plain People"}
    r << {:begin=>"BX5001", :end=>"BX5009", :text=>"Anglican Communion (General)"}
    r << {:begin=>"BX5011", :end=>"BX5207", :text=>"Church of England"}
    r << {:begin=>"BX5011", :end=>"BX5050", :text=>"General"}
    r << {:begin=>"BX5051", :end=>"BX5110", :text=>"History. Local divisions"}
    r << {:begin=>"BX5115", :end=>"BX5126", :text=>"Special parties and movements"}
    r << {:begin=>"BX5127", :end=>"BX5129.8", :text=>"Church of England and other churches"}
    r << {:begin=>"BX5130", :end=>"BX5132", :text=>"General"}
    r << {:begin=>"BX5133", :end=>"BX5133", :text=>"Sermons. Tracts. Addresses. Essays"}
    r << {:begin=>"BX5135", :end=>"BX5136", :text=>"Controversial works"}
    r << {:begin=>"BX5137", :end=>"BX5139", :text=>"Creeds and catechisms, etc."}
    r << {:begin=>"BX5140.5", :end=>"BX5147", :text=>"Liturgy and ritual"}
    r << {:begin=>"BX5148", :end=>"BX5149", :text=>"Sacraments"}
    r << {:begin=>"BX5150", :end=>"BX5182.5", :text=>"Government. Organization. Discipline"}
    r << {:begin=>"BX5183", :end=>"BX5187", :text=>"Religious communities. Conventual life. Religious"}
    r << {:begin=>"BX5194", :end=>"BX5195", :text=>"Cathedrals, churches, etc. in England and Wales"}
    r << {:begin=>"BX5197", :end=>"BX5199", :text=>"Biography"}
    r << {:begin=>"BX5200", :end=>"BX5207", :text=>"Dissent and nonconformity"}
    r << {:begin=>"BX5210", :end=>"BX5395", :text=>"Episcopal Church in Scotland"}
    r << {:begin=>"BX5410", :end=>"BX5595", :text=>"Church of Ireland"}
    r << {:begin=>"BX5596", :end=>"BX5598", :text=>"Church in Wales"}
    r << {:begin=>"BX5600", :end=>"BX5740", :text=>"Church of England outside of Great Britain"}
    r << {:begin=>"BX5601", :end=>"BX5620", :text=>"Anglican Church of Canada"}
    r << {:begin=>"BX5800", :end=>"BX5995", :text=>"Protestant Episcopal Church in the United States of America"}
    r << {:begin=>"BX5996", :end=>"BX6030", :text=>"Protestant Episcopal Church outside the United States"}
    r << {:begin=>"BX6051", :end=>"BX6093", :text=>"Reformed Episcopal Church"}
    r << {:begin=>"BX6101", :end=>"BX9999", :text=>"Other Protestant denominations"}
    r << {:begin=>"BX6101", :end=>"BX6193", :text=>"Adventists. (Millerites("}
    r << {:begin=>"BX6195", :end=>"BX6197", :text=>"Arminians. Remonstrants"}
    r << {:begin=>"BX6201", :end=>"BX6495", :text=>"Baptists"}
    r << {:begin=>"BX6201", :end=>"BX6227", :text=>"General"}
    r << {:begin=>"BX6231", :end=>"BX6328", :text=>"History. Local divisions"}
    r << {:begin=>"BX6329", :end=>"BX6329", :text=>"Baptists and other churches"}
    r << {:begin=>"BX6330", :end=>"BX6331.2", :text=>"Doctrine"}
    r << {:begin=>"BX6333", :end=>"BX6333", :text=>"Sermons. Tracts"}
    r << {:begin=>"BX6334", :end=>"BX6334", :text=>"Controversial works"}
    r << {:begin=>"BX6335", :end=>"BX6336", :text=>"Creeds. Catechisms"}
    r << {:begin=>"BX6337", :end=>"BX6337", :text=>"Service. Ritual. Liturgy"}
    r << {:begin=>"BX6338", :end=>"BX6339", :text=>"Sacraments"}
    r << {:begin=>"BX6340", :end=>"BX6346.3", :text=>"Government. Discipline"}
    r << {:begin=>"BX6349", :end=>"BX6470", :text=>"Individual branches"}
    r << {:begin=>"BX6480", :end=>"BX6490", :text=>"Individual Baptist churches"}
    r << {:begin=>"BX6493", :end=>"BX6495", :text=>"Biography"}
    r << {:begin=>"BX6551", :end=>"BX6593", :text=>"Catholic Apostolic Church. Irvingites"}
    r << {:begin=>"BX6651", :end=>"BX6693", :text=>"Christadelphians. Brothers of Christ"}
    r << {:begin=>"BX6751", :end=>"BX6793", :text=>"Christian Church"}
    r << {:begin=>"BX6801", :end=>"BX6843", :text=>"Christian Reformed Church"}
    r << {:begin=>"BX6901", :end=>"BX6997", :text=>"Christian Science"}
    r << {:begin=>"BX7003", :end=>"BX7003", :text=>"Christian Union"}
    r << {:begin=>"BX7020", :end=>"BX7060", :text=>"Church of God"}
    r << {:begin=>"BX7079", :end=>"BX7097", :text=>"Churches of God"}
    r << {:begin=>"BX7101", :end=>"BX7260", :text=>"Congregationalism"}
    r << {:begin=>"BX7301", :end=>"BX7343", :text=>"Disciples of Christ. Campbellites"}
    r << {:begin=>"BX7401", :end=>"BX7430", :text=>"Dowieism. Christian Catholic Church"}
    r << {:begin=>"BX7451", :end=>"BX7493", :text=>"Evangelical and Reformed Church"}
    r << {:begin=>"BX7556", :end=>"BX7556", :text=>"Evangelical United Brethren Church"}
    r << {:begin=>"BX7580", :end=>"BX7583", :text=>"Free Congregations (Germany). Freie Gemeinden"}
    r << {:begin=>"BX7601", :end=>"BX7795", :text=>"Friends. Society of Friends. Quakers"}
    r << {:begin=>"BX7801", :end=>"BX7843", :text=>"German Baptist Brethren. Church of the Brethren."}
    r << {:begin=>"BX7850", :end=>"BX7865", :text=>"German Evangelical Protestant Church of North America."}
    r << {:begin=>"BX7901", :end=>"BX7943", :text=>"German Evangelical Synod of North America"}
    r << {:begin=>"BX7990.H6", :end=>"BX.H69", :text=>"Holiness churches"}
    r << {:begin=>"BX8001", :end=>"BX8080", :text=>"Lutheran churches"}
    r << {:begin=>"BX8101", :end=>"BX8144", :text=>"Mennonites"}
    r << {:begin=>"BX8201", :end=>"BX8495", :text=>"Methodism"}
    r << {:begin=>"BX8525", :end=>"BX8528", :text=>"Millennial Dawnists. Jehovah(s Witnesses"}
    r << {:begin=>"BX8551", :end=>"BX8593", :text=>"Moravian Church. United Brethren. Unitas Fratrum."}
    r << {:begin=>"BX8601", :end=>"BX8695", :text=>"Mormons. Church of Jesus Christ of Latter-Day Saints"}
    r << {:begin=>"BX8701", :end=>"BX8749", :text=>"New Jerusalem Church. New Church. Swedenborgianism"}
    r << {:begin=>"BX8762", :end=>"BX8785", :text=>"Pentecostal churches"}
    r << {:begin=>"BX8799", :end=>"BX8809", :text=>"Plymouth Brethren. Darbyites"}
    r << {:begin=>"BX8901", :end=>"BX9225", :text=>"Presbyterianism. Calvinistic Methodism"}
    r << {:begin=>"BX9301", :end=>"BX9359", :text=>"Puritanism"}
    r << {:begin=>"BX9401", :end=>"BX9640", :text=>"Reformed or Calvinistic Churches"}
    r << {:begin=>"BX9675", :end=>"BX9675", :text=>"River Brethren. Brethren in Christ"}
    r << {:begin=>"BX9701", :end=>"BX9743", :text=>"Salvation Army"}
    r << {:begin=>"BX9751", :end=>"BX9793", :text=>"Shakers. United Society of Believers. Millennial Church"}
    r << {:begin=>"BX9801", :end=>"BX9869", :text=>"Unitarianism"}
    r << {:begin=>"BX9875", :end=>"BX9877.1", :text=>"United Brethren in Christ. Church of the United Brethren in"}
    r << {:begin=>"BX9881", :end=>"BX9882.95", :text=>"United Church of Canada"}
    r << {:begin=>"BX9884", :end=>"BX9886", :text=>"United Church of Christ"}
    r << {:begin=>"BX9887", :end=>"BX9887", :text=>"United Evangelical Church"}
    r << {:begin=>"BX9889", :end=>"BX9889", :text=>"United Missionary Church"}
    r << {:begin=>"BX9901", :end=>"BX9969", :text=>"Unviersalism. Universalists"}
    r << {:begin=>"BX9975", :end=>"BX9975", :text=>"Volunteers of America"}
    r << {:begin=>"BX9980", :end=>"BX9980", :text=>"Walloon Church"}
    r << {:begin=>"BX9998", :end=>"BX9998", :text=>"Other beliefs and movements akin to Christianity"}
    r << {:begin=>"BX9999", :end=>"BX9999", :text=>"Independent churches, parishes, societies, etc."}
    r
  end
end
