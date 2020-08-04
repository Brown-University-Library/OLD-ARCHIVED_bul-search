class Building
    def self.name(code)
        return nil if code == nil
        code = code.strip.downcase
        name = self.all[code]
        if name == nil
            name = self.all[code[0]]
            if code[0] == 'e'
                name = "Online"
            end
        end
        name
    end

    def self.all
        @all ||= begin
            data = {}
            data['q'] = 'Annex'
            data['h'] = 'Hay'
            data['j'] = 'John Carter Brown'
            data['o'] = 'Orwig'
            data['r'] = 'Rockefeller'
            data['s'] = 'Sciences'
            data['a'] = 'Hay'
            data['cass'] = 'Rockefeller'
            data['chin'] = 'Rockefeller'
            data['chref'] = 'Rockefeller'
            data['cours'] = 'Rockefeller'
            data['eacg'] = 'Rockefeller'
            data['eacr'] = 'Rockefeller'
            data['eacs'] = 'Rockefeller'
            data['japan'] = 'Rockefeller'
            data['jaref'] = 'Rockefeller'
            data['jmap'] = 'Rockefeller'
            data['koref'] = 'Rockefeller'
            data['korea'] = 'Rockefeller'
            data['linc'] = 'Hay'
            data['linrf'] = 'Hay'
            data['lowc'] = 'Hay'
            data['qhs'] = 'Hay'
            data['mddvd'] = 'Sciences'
            data['mdvid'] = 'Sciences'
            data['stor'] = 'Rockefeller'
            data['vc'] = 'John Carter Brown'
            data['xdoc'] = 'Rockefeller'
            data['xfch'] = 'Rockefeller'
            data['xrom'] = 'Rockefeller'
            data['xxxxx'] = 'Rockefeller'
            data['zd'] = 'Rockefeller'
            data['gar'] = 'Rockefeller'
            data['zdcom'] = 'Rockefeller'
            data
        end
    end
end

