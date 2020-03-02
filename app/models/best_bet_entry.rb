class BestBetEntry < ActiveRecord::Base
    # Returns all the terms associated with a given BestBetEntry
    def terms()
        @terms ||= begin
            BestBetTerm.where(best_bet_entry_id: self.id).order(:term)
        end
    end

    # Delete a BestBetEntry and its associated BestBetTerms
    def delete()
        # Delete the terms first...
        terms().each do |term|
            term.delete()
        end
        # ...and then the BestBet entry
        super
        BestBetEntry.force_cache_reload()
    end

    # Returns an array of hashes with all the BestBetEntries and their search terms.
    # This is used to display the information in the BestBets home page (/bestbets).
    #
    # We are using an array of hashes here (instead of an array of BestBetEntry + BestBetTerms)
    # because I want to bypass Rails' lazy loading and force it to load all the data into the cache.
    # TODO: Figure out if there is a Rails-way of doing this.
    #
    def self.all_cached()
        Rails.cache.fetch("best_bet_cache", expires_in: 30.minute) do
            entries = []
            BestBetEntry.all.order(:name).each do |entry|
                cache_entry = {
                    id: entry.id,
                    name: entry.name,
                    url: entry.url,
                    description: entry.description,
                    terms: []
                }
                BestBetTerm.where(best_bet_entry_id: entry.id).order(:term).each do |term|
                    cache_entry[:terms] << term.term
                end
                entries << cache_entry
            end
            entries
        end
    end

    # Searches the cache for a BestBetEntry by term
    def self.search(term)
        term = (term || "").strip
        bb = terms_cached[term]
        bb
    end

    # Returns a hash in which each key corresponds to a search term
    # and its value is the BestBetEntry for that term. For example:
    #   {
    #       "pubmed": <BestBetEntry.id 123 Pubmed>,
    #       "pub med ": <BestBetEntry.id 123 Pubmed>,
    #       "acm": <BestBetEntry.id 222 ACM Digital Library>
    #       "us poets": <BestBetEntry.id 333 American Poetry>
    #   }
    # This is used to perform searches by term by using Ruby's native
    # key search.
    def self.terms_cached()
        Rails.cache.fetch("best_bet_terms_cache", expires_in: 30.minute) do
            terms_cache = {}
            BestBetEntry.all.order(:name).each do |entry|
                BestBetTerm.where(best_bet_entry_id: entry.id).each do |term|
                    key = (term.term || "").strip
                    if key != ""
                        terms_cache[key] = entry
                    end
                end
            end
            terms_cache
        end
    end

    def self.force_cache_reload()
        Rails.cache.delete("best_bet_cache")
        Rails.cache.delete("best_bet_terms_cache")
    end

    # Updates a BestBetEntry and its related BestBetTerms.
    #
    # Params represents the hash that we got in the controller when
    # the user saves the HTML form.
    def self.save_form(params)
        bb = BestBetEntry.find(params["id"])

        # Save the best bet entry main information...
        bb.name = params["name"]
        bb.url = params["url"]
        bb.description = params["description"]
        bb.save()

        # ...then the existing search terms
        term_keys = params.keys.select {|x| x.start_with?("term_id_") }
        term_keys.each do |key|
            id = key[8..-1]
            value = (params[key] || "").strip
            if value == ""
                BestBetTerm.delete(id)
            else
                bt = BestBetTerm.find(id)
                bt.term = value
                bt.save()
            end
        end

        # ...then any new terms
        # (notice that we ignore of the new_term_id_xxx and we let Rails assign it its own id)
        term_keys = params.keys.select {|x| x.start_with?("new_term_id_") }
        term_keys.each do |key|
            value = (params[key] || "").strip
            if value == ""
                # ignore it
            else
                # add the new term and link it to the proper BestBetEntry
                bt = BestBetTerm.new()
                bt.best_bet_entry_id = bb.id
                bt.term = value
                bt.save()
            end
        end

        force_cache_reload()
    end

    # Imports a hash with the data as downloaded from Google Sheet
    #
    # TODO: Figure out logic associated with the database value
    #
    def self.import(rows)
        BestBetEntry.delete_all()
        rows.each do |row|
            bb = BestBetEntry.new()
            bb.name = (row["name"] || "").strip
            bb.database = (row["database"] || "").strip
            bb.description = (row["description"] || "").strip
            bb.url = (row["url"] || "").strip
            bb.save()
            (row["queries"] || "").split(";").each do |term|
                term = term.strip
                if term != ""
                    bt = BestBetTerm.new()
                    bt.best_bet_entry_id = bb.id
                    bt.term = term
                    bt.save
                end
            end
        end
        force_cache_reload()
    end

    # Gathers all the entries and search terms in an array ready for download
    def self.export()
        rows = []
        BestBetEntry.all_cached.each do |bb|
            row = []
            row << bb[:name]
            row << bb[:database]
            row << bb[:description]
            row << bb[:url]

            terms = []
            bb[:terms].each do |term|
                terms << term
            end
            row << terms.join(";")

            rows << row
        end
        rows
    end

    # Produces a string with all the entries and search terms in
    # tab-separated-values format
    def self.export_tsv()
        tsv = []
        export().each do |row|
            # Strip \r, \n, and \t from the content since those are
            # our delimiters for the export.
            row = row.map do |cell|
                (cell || "").gsub("\n", " ").gsub("\r", " ").gsub("\t", " ")
            end
            tsv << row.join("\t")
        end
        tsv.join("\r\n")
    end
end