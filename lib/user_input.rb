module UserInput
  class Cleaner
    def self.clean(value)
      value ||= ""
      value.each_char.select{|v| v =~ /[\w\- \.]/}.join("")
    end
    def self.clean_id(id)
      id ||= ""
      id.each_char.select{|v| v =~ /[\w]/}.join("")
    end
  end
end
