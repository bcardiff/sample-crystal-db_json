require "kemal"
require "sqlite3"
require "mysql"
require "pg"

database_url = ARGV[0]
puts "opening #{database_url}"
db = DB.open database_url

def table_names(db)
  sql = case db.uri.scheme
        when "postgres"
          "SELECT tablename FROM pg_catalog.pg_tables;"
        when "mysql"
          "show tables;"
        when "sqlite3"
          "SELECT name FROM sqlite_master WHERE type='table';"
        else
          raise "table_names not implemented for #{db.uri.scheme}"
        end

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
  when Char, Array(PG::CharArray)
  when PG::Geo::Point, PG::Geo::Box
  when PG::Geo::Circle, PG::Geo::Line
  when PG::Geo::LineSegment, PG::Geo::Path
  when PG::Geo::Polygon, PG::Numeric
    # PG driver returns many types that do not handle json conversion directly
  else
    value
  end
end

Kemal.run
db.close
