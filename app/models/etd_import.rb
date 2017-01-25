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
      # fetch all dissertations (paginated via rows and start)
      url = "#{api_url}?q=ir_collection_name:Dissertations&rows=#{rows}&start=#{start}"
      api_response = HttpUtil::HttpJson.get(url)
      docs = api_response["response"]["docs"]
      break if docs.count == 0
      docs.each do |etd|
        # TODO: commit at the end of the batch, not on each record
        record = bib_record_from_etd(etd)
        puts "\t#{etd['pid']}, #{record.save}"
      end
      start += rows
      page += 1
    end
  end

  def one_from_bdr(id)
    api_url = ENV["BDR_ITEM_API_URL"]
    # TODO: This enforces security which means I am not able to get the metadata
    # for an embargoed item (whereas I can get it with the search API)
    raise "No value for BDR_ITEM_API_URL was found the environment" if api_url == nil
    url = "#{api_url}#{id}/"
    etd = HttpUtil::HttpJson.get(url)
    record = bib_record_from_etd(etd)
    record.save
  end

  private
    def bib_record_from_etd(etd)
      bib = BibRecord.new
      bib.id = etd["pid"]
      bib.updated_dt = etd["fed_last_modified_dsi"]
      bib.oclc = [] # leave empty

      # primary_title, mods_title_full_tsim, mods_title_full_primary_tsi, brief.title,
      bib.title_t << etd["primary_title"]
      bib.title_display = etd["primary_title"]

      bib.opensearch_display = []

      # creator, creator_string
      bib.author_display = etd["creator"]
      bib.author_addl_display = [] # always empty?
      bib.author_t << etd["creator"] # TODO: figure out what we do in Traject
      bib.author_addl_t = []

      bib.physical_display = [] # born digital

      bib.pub_date = etd["copyrightDate_year_ssim"] || []
      # bib.pub_date_sort is calculated

      bib.online_b = true
      bib.language_facet = to_josiah_langs(etd["mods_language_code_ssim"])
      bib.format = "Thesis/Dissertation"
      bib.location_code_t = ["BDR"] # leave empty instead?
      bib.subject_t = etd["mods_subject_ssim"]

      # I might need to dump some of the ETD fields to marc_display
      # so that the rest of the system picks them up. The show page
      # picks stuff from the marc_display page, for example the abstract.
      bib.marc_display = nil

      # new field
      bib.abstract_display = etd["abstract"]
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
      if bdr_lang == "eng" || bdr_lang == "English" then
        "English"
      else
        nil
      end
    end
end
