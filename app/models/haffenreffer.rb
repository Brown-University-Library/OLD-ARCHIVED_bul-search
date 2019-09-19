require "./app/models/museum_plus.rb"

class Haffenreffer
    def get_source_items()
        return [] if ENV["MP_USER"] == nil
        @mp = MuseumPlus.new(ENV["MP_URL"], ENV["MP_USER"], ENV["MP_PASSWORD"])
        r = @mp.search()
        r
    end

    def get_source_items_raw()
        return nil if ENV["MP_USER"] == nil
        @mp = MuseumPlus.new(ENV["MP_URL"], ENV["MP_USER"], ENV["MP_PASSWORD"])
        xml = @mp.search_raw()
        xml
    end

    def update_solr(items)
        bib_records = items.map {|item| bib_record_from_mp(item)}
        BibRecord.save_batch(bib_records)
    end

    def bib_record_from_mp(item)
        bib = BibRecord.new
        bib.record_source_s = "MP_HAF"
        bib.id = "MP_HAF_" + item[:id].to_s
        bib.updated_dt = DateTime.now.new_offset(0).to_s[0..18] + "Z"
        bib.title_t << item[:title]
        bib.title_display = item[:title]
        bib.opensearch_display = []

        bib.author_display = []
        bib.author_spell = []
        bib.author_t = []
        if item[:people]
            bib.author_display = [item[:people]]
            bib.author_t = [item[:people]]
        end

        bib.author_addl_display = []
        bib.author_addl_t = []

        bib.author_facet = []
        bib.new_uniform_title_author_display = nil

        bib.physical_display = item[:dimensions]

        bib.pub_date = []

        bib.online_b = true
        bib.access_facet = "Online"

        bib.language_facet = "English"
        bib.format = "Museum Artifact"
        bib.location_code_t = ["MP_HAF"] # leave empty instead?

        bib.subject_t = nil
        bib.topic_facet = nil

        bib.marc_display = nil

        item_url = "https://de1.zetcom-group.de/MpWeb-mpBristolHaffenreffer/v?autologon=1#!m/Object/#{item[:id]}/form/ObjCatalogView"
        bib.url_fulltext_display = [item_url]
        access_text = "More information at the Haffenreffer Museum of Anthropology"
        bib.url_suppl_display = [access_text]

        # new fields
        bib.abstract_display = item[:description]
        bib.bdr_notes_display = nil
        bib
    end
end