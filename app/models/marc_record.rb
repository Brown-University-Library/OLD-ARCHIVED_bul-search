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
  # the string values for all fields that match the
  # field_code and subfield_code. For example if there
  # are many fields with code "028" and subfield "a"
  # it will return an array with all of them.
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

  # Receives a field object and a subfield code (e.g. "a") and
  # and returns the first value found. The field object is
  # expected to be one of the fields returned by `field(code)`.
  #
  # We use this method to pick a subfield value from a very specific
  # field (e.g. subfield "a" from the second "028" field in the record)
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
