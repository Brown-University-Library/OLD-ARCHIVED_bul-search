class Dashboard
    def self.bibs_by_range(from, to)
        data = Callnumber.get_by_range(from, to)
        bibs = []
        data.each do |x|
            # TODO: Get the bib/item information for each record
            bibs << x
        end
        bibs
    end

    def self.collection(id)
        data = nil
        case
        when id == "local1"
            data = {id: id, name: "Local List #1", description: "my sample list", bibs: [], ranges: []}
            data[:ranges] << {from: "NA 028000D800", to: "NA 0999"}
            data[:ranges] << {from: "PQ 809812O380A122 000 2009", to: "PQ 9999ZZZ"}
            data[:ranges].each do |range|
                data[:bibs] += Dashboard.bibs_by_range(range[:from], range[:to])
            end
        when id == "local2"
            data = {id: id, name: "Local List #2", description: "another sample list", bibs: [], ranges: []}
            data[:ranges] << {from: "DF 028700", to: "DF 099999"}
            data[:ranges] << {from: "R  055300H800", to: "R  095300H800"}
            data[:ranges].each do |range|
                data[:bibs] += Dashboard.bibs_by_range(range[:from], range[:to])
            end
        end
        data
    end
end
