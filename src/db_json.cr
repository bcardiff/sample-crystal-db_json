require "kemal"
require "sqlite3"

database_url = "sqlite3://#{ARGV[0]}"
puts "opening #{database_url}"
db = DB.open database_url

def table_names(db)
  sql = "SELECT name FROM sqlite_master WHERE type='table';"
  db.query_all(sql, as: String)
end

get "/" do |env|
  env.response.content_type = "application/json"
  table_names(db).to_json
end

get "/:table_name" do |env|
  env.response.content_type = "application/x-ndjson"
  table_name = env.params.url["table_name"]
  db.query "select * from #{table_name}" do |rs|
    col_names = rs.column_names
    rs.each do
      write_ndjson(env.response.output, col_names, rs)
      # force chunked response even on small tables
      env.response.output.flush
    end
  end
end

def write_ndjson(io, col_names, rs)
  io.json_object do |object|
    col_names.each do |col|
      object.field col, transform(rs.read)
    end
  end
  io << "\n"
end

def transform(value)
  case value
  when Slice(UInt8)
    value.to_a
  else
    value
  end
end

Kemal.run
db.close
