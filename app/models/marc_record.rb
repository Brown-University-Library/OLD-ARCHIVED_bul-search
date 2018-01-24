class MarcRecord
  attr_reader :fields

  def initialize(marc_str)
    if marc_str == nil
      @fields = []
    else
      data = JSON.parse(marc_str)
      @fields = data.fetch("fields", [])
    end
  end

  # Returns the values for a MARC field.
  # For some fields this is an array of string (e.g. 001)
  # whereas for others (e.g. 015) is an array of Hash objects
  # with subfield definitions.
  def field(code)
    values = []
    @fields.each do |marc_field|
      if marc_field.keys.first == code && marc_field[code] != nil
        values << marc_field[code]
      end
    end
    values
  end

  # Receives a field code (e.g. "504") and subfield
  # code (e.g. "a") and returns an array with the
  # string values for a field code/subfield.
  def subfield_values(field_code, subfield_code)
    values = []
    fields = field(field_code)
    fields.each do |field|
      field["subfields"].each do |subfield|
        if subfield.keys.first == subfield_code
          subfield.values.each do |value|
            if value != nil
              values << value.strip
            end
          end
        end
      end
    end
    values
  end

  # Receives a field object and a subfield code (e.g. "a")
  # and returns the first value found.
  #
  # TODO: I don't like how hidden the difference between methods
  # subfield_values() and subfield_value() is. It's too easy to
  # get confused. I should refactor these methods to make more
  # obvious the difference in input and output.
  #
  def subfield_value(field, subfield_code)
    field["subfields"].each do |subfield|
      if subfield.keys.first == subfield_code
        # Could there be many values???
        value = subfield.values.first
        value = value.strip if value != nil
        return value
      end
    end
    nil
  end
end
