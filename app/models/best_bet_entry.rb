class BestBetEntry < ActiveRecord::Base
    attr_accessor :search_terms

    # Returns all the terms associated with a given BestBetEntry
    def terms()
        @queries ||= begin
            BestBetTerm.where(best_bet_entry_id: self.id).order(:term)
        end
    end

    def delete()
        # Delete the terms first...
        terms().each do |term|
            term.delete()
        end
        # ...and then the BestBet entry
        super
    end

    def self.all_ordered()
        Rails.cache.fetch("best_bet_cache", expires_in: 30.minute) do
            entries = BestBetEntry.all.order(:name)
            entries
        end
    end

    def self.force_reload()
        Rails.cache.delete("best_bet_cache")
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

        force_reload()
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
    end

    # Gathers all the entries and search terms in an array ready for download
    def self.export()
        rows = []
        BestBetEntry.all.each do |bb|
            row = []
            row << bb.name
            row << bb.database
            row << bb.description
            row << bb.url

            terms = []
            bb.terms.each do |term|
                terms << term.term
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
            row = row.map {|cell| cell.gsub("\n", " ").gsub("\r", " ").gsub("\t", " ")}
            tsv << row.join("\t")
        end
        tsv.join("\r\n")
    end
end