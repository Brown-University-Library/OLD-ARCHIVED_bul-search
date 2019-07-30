class CallnumberUtils
    def self.normalized(text)
        text.upcase.scan(/\w+|\d+/).join("|")
    end

    def self.is_callnumber?(text)
        return false if text == nil
        norm = self.normalized(text)
        norm.include?("|")
    end
end