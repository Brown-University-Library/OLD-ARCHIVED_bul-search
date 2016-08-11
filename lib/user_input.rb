module UserInput
  class Cleaner
    def self.clean(value)
      value ||= ""
      value.each_char.select{|v| v =~ /[\w\- \.]/}.join("")
    end
  end
end
