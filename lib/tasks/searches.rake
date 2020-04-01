namespace :josiah do
  desc "Parses `searches` table and populates `searches_params` table"
  task "searches_parse_params" => :environment do |_cmd, args|
    count = 0
    # This code does not clean the current data before parsing new
    # searches and therefore running it more than once will create
    # duplicates in the searches_params table.
    #
    # Truncate data in searches_params before running this code.
    #
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

  desc "Delete the oldest records in the search and user tables"
  task "searches_prune" => :environment do |_cmd, args|
    months = 3
    min_date = (Date.today - (months * 30)).to_s
    batch_size = 15000
    puts "Deleting searches older than #{min_date} (batch size #{batch_size})"
    prune_searches(min_date, batch_size)
    puts "Deleting guest users older than #{min_date} (batch size #{batch_size})"
    prune_users(min_date, batch_size)
  end

  desc "Returns a count of how many searches and users are old (and could be deleted)"
  task "searches_count" => :environment do |_cmd, args|
    months = 3
    min_date = (Date.today - (months * 30)).to_s
    count = count_searches(min_date)
    puts "Searches older than #{min_date}: #{count}"
    count = count_users(min_date)
    puts "Users older than #{min_date}: #{count}"
  end

  desc "Outputs to the console the main columns from searches_params"
  task "searches_report" => :environment do |_cmd, args|
    output_searches_params()
  end

end

def process_searches
  batch_size = 1000
  max_id = max_searches_id()
  start_id = min_searches_id()
  end_id = start_id + batch_size
  while start_id <= max_id
    batch = get_searches_batch(start_id, end_id)
    yield batch
    start_id += batch_size
    end_id += batch_size
  end
end


def get_searches_batch(start_id, end_id)
  sql = "select id, query_params from searches where id between #{start_id} and #{end_id};"
  rows = ActiveRecord::Base.connection.exec_query(sql).rows
  batch = []
  rows.each do |row|
    begin
      id = row[0].to_i
      query_params = row[1]
      hash = YAML.load(query_params)
      batch << {id: id, values: hash}
    rescue Exception => ex
      puts "Error - row: #{row}, #{ex}"
    end
  end
  batch
end

def output_searches_params
  sql = "select id, search_id, q, search_field, action, controller from searches_params where q is not null;"
  rows = ActiveRecord::Base.connection.exec_query(sql).rows
  batch = []
  rows.each do |row|
    begin
      id = row[0].to_i
      search_id = row[1].to_i
      q = (row[2] || "(empty)")[0..80]
      field = row[3]
      action = row[4]
      controller = row[5]
      puts "#{id}\t#{search_id}\t#{q}\t#{field}\t#{action}\t#{controller}"
    rescue Exception => ex
      puts "Error on row: #{row}, #{ex}"
    end
  end
  batch
end

def prune_searches(min_date, batch_size)
  while count_searches(min_date) > 0 do
    sql = "DELETE FROM searches " +
    "WHERE created_at < '#{min_date}' AND user_id IS NULL " +
    "ORDER BY created_at " +
    "LIMIT #{batch_size};"
    ActiveRecord::Base.connection.execute(sql)
  end
end

def prune_users(min_date, batch_size)
  while count_users(min_date) > 0 do
    sql = "DELETE FROM users " +
    "WHERE created_at < '#{min_date}' AND guest = 1 " +
    "ORDER BY created_at " +
    "LIMIT #{batch_size};"
    ActiveRecord::Base.connection.execute(sql)
  end
end

def count_searches(min_date)
  sql = "SELECT count(id) FROM searches WHERE created_at < '#{min_date}' AND user_id IS NULL;"
  rows = ActiveRecord::Base.connection.exec_query(sql).rows
  rows[0][0].to_i
end

def count_users(min_date)
  sql = "SELECT count(id) FROM users WHERE created_at < '#{min_date}' AND guest = 1;"
  rows = ActiveRecord::Base.connection.exec_query(sql).rows
  rows[0][0].to_i
end

def min_searches_id
  sql = "select min(id) from searches;"
  rows = ActiveRecord::Base.connection.exec_query(sql).rows
  rows[0][0].to_i
end

def max_searches_id
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
