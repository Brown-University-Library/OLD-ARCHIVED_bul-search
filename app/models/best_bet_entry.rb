class BestBetEntry < ActiveRecord::Base
    def queries()
        @queries ||= begin
            puts "loading queries for #{self.id}"
            BestBetTerm.where(best_bet_entry_id: self.id)
        end
    end

    # Imports a hash with the data as downloaded from Google Sheet
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

    def self.export()
        rows = []
        BestBetEntry.all.each do |bb|
            row = []
            row << bb.name
            row << bb.database
            row << bb.description
            row << bb.url

            queries = []
            bb.queries.each do |query|
                queries << query.term
            end
            row << queries.join(";")

            rows << row
        end
        rows
    end

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