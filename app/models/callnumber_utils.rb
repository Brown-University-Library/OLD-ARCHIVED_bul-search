class CallnumberUtils
    def self.tokenized(text)
        text.upcase.scan(/[A-Z]+|\d+/).join("|")
    end

    def self.is_callnumber?(text)
        return false if text == nil
        norm = self.normalized(text)
        norm.include?("|")
    end
end