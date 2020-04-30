require "./app/models/string_utils.rb"
require "./app/models/item_data.rb"

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
  # code (e.g. "a" or "abc") and returns an array
  # with the the string values for all fields that
  # match the field_code and subfield_codes. For
  # example if there are many fields with code "504"
  # and subfield "a" it will return an array with
  # all of them. If multiple subfield codes are
  # indicated (e.g. "abc") their values are concatenated
  # with " > ".
  def subfield_values(field_code, subfield_codes, allow_many = false)
    values = []
    fields = field(field_code)
    fields.each do |field|
      tokens = []
      field["subfields"].each do |subfield|
        key = subfield.keys.first
        if subfield_codes.include?(key)
          value = (subfield[key] || "").strip
          if value != ""
            tokens << value
            # This check is to preserve backwards compatibility
            # for when we did not expect multi-values
            # (e.g. many 998|a in a single field)
            break if !allow_many
          end
        end
      end
      if tokens.count > 0
        values << tokens.join(" > ")
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

  # Extracts data from the 945 fields for the MARC record.
  def items
    items = []
    f_090a = subfield_values("090", "a").first
    f_090b = subfield_values("090", "b").first
    f_090f = subfield_values("090", "f").first  # e.g. 1-SIZE

    # Item data is on the 945 fields.
    fields.each_with_index do |marc_field, index|
      next if marc_field.keys.first != "945"

      f_945 = marc_field["945"]

      location_code = subfield_value(f_945, "l")
      barcode = subfield_value(f_945, "i")
      id = subfield_value(f_945, "y")
      bookplate_code = subfield_value(f_945, "f")

      # callnumber
      part1 = subfield_value(f_945, "a")
      part2 = subfield_value(f_945, "b")
      if part1 != nil || part2 != nil
        base_number = StringUtils.clean_join(f_090f, part1, part2)
      else
        base_number = StringUtils.clean_join(f_090f, f_090a, f_090b)
      end
      volume = subfield_value(f_945, "c")
      copy = subfield_value(f_945, "g") || ""
      if copy == "1" || copy == "0"
        copy = ""
      elsif copy > "1"
        copy = "c.#{copy}"
      end
      call_number = StringUtils.clean_join(base_number, volume, copy)
      if call_number.end_with?("\\")
        call_number = call_number[0..-2]
      end

      # bookplate URL and display text are on the next 996
      i = index + 1
      while i < fields.count
        if fields[i].keys.first == "945"
          # ran into a new 945, no bookplate info found.
          break
        end

        if fields[i].keys.first == "996"
          f_996 = fields[i]["996"]
          bookplate_url = subfield_value(f_996, "u")
          bookplate_display = subfield_value(f_996, "z")
          # parsed a 996, we should be done.
          break
        end
        i += 1
      end

      suppressed = subfield_value(f_945, "o") == "n"
      if !suppressed
        item = ItemData.new(id, barcode)
        item.location_code = location_code
        item.bookplate_code = bookplate_code
        item.bookplate_url = bookplate_url
        item.bookplate_display = bookplate_display
        item.copy = copy
        item.volume = volume
        item.call_number = call_number
        item.suppressed = false
        item.checkout_total = (subfield_value(f_945, "u") || "").to_i
        item.checkout_2015_plus = (subfield_value(f_945, "w") || "").to_i
        item.created_date = marc_string_to_date(subfield_value(f_945, "z"))
        items << item
      end
    end
    items
  end

  def created_date()
    date_value("907", "c")
  end

  def cataloged_date()
    date_value("998", "b")
  end

  def date_value(field_code, subfield_code)
    values = subfield_values(field_code, subfield_code)
    return nil if values.count == 0
    values.each do |value|
      date = marc_string_to_date(value)
      if date != nil
        # Return the first valid date
        return date
      end
    end
    nil
  end

  def marc_string_to_date(marc_date)
    return nil if marc_date == nil
    Date.strptime(marc_date,"%m-%d-%y")
  rescue ArgumentError
    nil
  end

  def subjects()
    # Definitions taken from bulmarc (/lib/bulmarc/record.rb)
    values = []
    values += subfield_values("600", "abcdfklmnopqrtvxyz", true)
    values += subfield_values("610", "abfklmnoprstvxyz", true)
    values += subfield_values("611", "abcdefgklnpqstvxyz", true)
    values += subfield_values("630", "adfgklmnoprstvxyz", true)
    values += subfield_values("650", "abcvxyz", true)
    values += subfield_values("651", "avxyz", true)
    values
  end
end
