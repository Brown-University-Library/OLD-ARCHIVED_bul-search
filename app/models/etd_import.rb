require "./lib/http_json.rb"

# BRD API
#
# Item data (does not work for embargoed thesis)
# https://repository.library.brown.edu/studio/item/bdr%3A297551/?format=json
#
# Search API (gives metadata even for protected items)
# https://repository.library.brown.edu/api/search/?q=pid:bdr\:320661
# https://repository.library.brown.edu/api/search/?q=ir_collection_name:Dissertations&rows=20

class EtdImport

  def all_from_bdr()
    api_url = ENV["BDR_SEARCH_API_URL"]
    raise "No value for BDR_SEARCH_API_URL was found the environment" if api_url == nil
    rows = 100
    start = 0
    page = 1
    while true
      puts "Processing page #{page}"
      bib_records = []
      # fetch all dissertations (paginated via rows and start)
      url = "#{api_url}?q=ir_collection_name:Dissertations&rows=#{rows}&start=#{start}"
      api_response = HttpUtil::HttpJson.get(url)
      docs = api_response["response"]["docs"]
      break if docs.count == 0
      docs.each do |etd|
        bib_records << bib_record_from_etd(etd)
      end
      if !BibRecord.save_batch(bib_records)
        puts "\terror saving page #{page}!"
      end
      start += rows
      page += 1
    end
  end

  def one_from_bdr(id)
    api_url = ENV["BDR_SEARCH_API_URL"]
    raise "No value for BDR_SEARCH_API_URL was found the environment" if api_url == nil
    params = "pid:" + id.gsub(':', '%5C%3A')
    url = "#{api_url}?q=#{params}"
    http_response = HttpUtil::HttpJson.get(url)
    docs = http_response["response"]["docs"]
    if docs.count == 1
      etd = docs.first
      record = bib_record_from_etd(etd)
      record.save
    else
      puts "ERROR: Records found #{docs.count}"
      false
    end
  end

  private
    def bib_record_from_etd(etd)
      bib = BibRecord.new
      bib.record_source_s = "BDR"
      bib.id = etd["pid"]
      bib.updated_dt = etd["fed_last_modified_dsi"]
      bib.oclc = [] # leave empty

      bib.title_t << etd["primary_title"]
      bib.title_display = etd["primary_title"]

      bib.opensearch_display = []

      # TODO: implement some of the parsing that we do in Traject when importing
      # author values (e.g. trim punctuation, handle alternate scripts)
      creator = (etd["creator"] || [])
      bib.author_display = creator.first
      bib.author_spell = creator
      bib.author_t = creator
      # bib.author_unsteam_search = creator
      bib.author_vern_display = creator.first

      contributors = (etd["contributor"] || [])
      bib.author_addl_display = creator.first
      bib.author_addl_t = etd["contributor"]
      # bib.author_addl_unsteam_search = etd["contributor"]

      bib.author_facet = creator + contributors
      bib.new_uniform_title_author_display = creator.first


      bib.physical_display = etd["mods_physicalDescription_extent_ssim"]

      bib.pub_date = etd["copyrightDate_year_ssim"] || []
      # bib.pub_date_sort is calculated

      bib.online_b = true
      bib.access_facet = "Online"

      bib.language_facet = to_josiah_langs(etd["mods_language_code_ssim"])
      bib.format = "Thesis/Dissertation"
      bib.location_code_t = ["BDR"] # leave empty instead?

      bib.subject_t = etd["mods_subject_ssim"]
      bib.topic_facet = etd["mods_subject_fast_ssim"]

      # I might need to dump some of the ETD fields to marc_display
      # so that the rest of the system picks them up. The show page
      # picks stuff from the marc_display page, for example the abstract.
      bib.marc_display = nil

      # TODO: handle empty ENV variable
      item_url = ENV["BDR_ITEM_URL"] + bib.id
      bib.url_fulltext_display = [item_url]
      access_text = "Available online at the Brown Digital Repository"
      if etd["_display_public_bsi"] == false
        access_text += " (access might be restricted to Brown University users)"
      end
      bib.url_suppl_display = [access_text]

      # new fields
      bib.abstract_display = etd["abstract"]
      bib.bdr_notes_display = etd["note"]
      bib
    end

    def to_josiah_langs(bdr_langs)
      return [] if bdr_langs == nil
      langs = []
      bdr_langs.each do |bdr_lang|
        lang = to_josiah_lang(bdr_lang)
        if lang != nil && !langs.include?(lang)
          langs.push(lang)
        end
      end
      langs
    end

    def to_josiah_lang(bdr_lang)
      case bdr_lang
      when "eng"
        "English"
      when "por"
        "Portuguese"
      when "fre"
        "French"
      when "ita"
        "Italian"
      when "spa"
        "Spanish"
      when "ger"
        "German"
      else
        nil
      end
    end
end
