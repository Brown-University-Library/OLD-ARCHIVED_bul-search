namespace :josiah do
  desc "Gets information about the keys stored in the `searches` table"
  task "searches_stats" => :environment do |_cmd, args|
    params = []
    process_searches do |batch|
      batch.each do |search|
        search[:values].keys.each do |key|
          if key != "_" && !params.include?(key)
            puts "#{key} (#{search[:id]})"
            params << key
          end
        end
      end
    end
    puts "====="
    puts params
  end

  desc "Parses `searches` table and populates `searches_params` table"
  task "searches_parse_params" => :environment do |_cmd, args|
    count = 0
    process_searches do |batch|
      batch.each do |search|
        values = clean_search_values(search[:values])
        values["search_id"] = search[:id]
        begin
          count += 1
          if (count % 10000) == 0
            puts "Processing record: #{count}"
          end
          sp = SearchesParams.new(values)
          sp.save!
        rescue Exception => ex
          puts "Error - ID: #{search[:id]}, #{ex}"
        end
      end
    end
  end
end


def process_searches
  max_id = max_searches_id
  start_id = 1
  end_id = start_id + 10
  while start_id <= max_id
    batch = get_searches_batch(start_id, end_id)
    yield batch
    start_id += 10
    end_id += 10
  end
end


def get_searches_batch(start_id, end_id)
  sql = "select id, query_params from searches where id between #{start_id} and #{end_id};"
  rows = ActiveRecord::Base.connection.exec_query(sql).rows
  batch = []
  rows.each do |row|
    id = row[0].to_i
    query_params = row[1]
    hash = YAML.load(query_params)
    batch << {id: id, values: hash}
  end
  batch
end


def max_searches_id
  # return 50000
  sql = "select max(id) from searches;"
  rows = ActiveRecord::Base.connection.exec_query(sql).rows
  rows[0][0].to_i
end

def is_valid_field?(field)
  if field == "_" || field == "i" || field == "test" ||
    field == "frm" || field == "lKq6Q6lq" || field == "esrc" ||
    field == "rct" || field == "clientAction" ||
    field.start_with?("bad_") || field.start_with?("whatever")
    return false
  end
  return is_alphanum?(field)
end

def is_alphanum?(value)
  !value.match(/[^A-Za-z1-9_]/)
end

def clean_search_values(hash)
  values = {}
  hash.keys.each do |key|
    case key
    when "id"
      clean_key = "other_id"
    when "facet.page"
      clean_key = "facet_page"
    when "facet.sort"
      clean_key = "facet_sort"
    when "_field"
      clean_key = "x_field"
    when "Publication date"
      clean_key = "publication_date"
    when "f%5Bauthor_facet%5D%5B%5D"
      clean_key = "f_author_facet"
    when "f%5Blanguage_facet%5D%5B%5D"
      clean_key = "f_language_facet"
    when "f%5Bbuilding_facet%5D%5B%5D"
      clean_key = "f_building_facet"
    else
      if is_valid_field?(key)
        clean_key = key
      else
        # don't process this field
        next
      end
    end
    if hash[key] != nil
      values[clean_key] = hash[key] # .to_s.strip
    end
  end
  values
end