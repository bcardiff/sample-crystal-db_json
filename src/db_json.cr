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
  unless table_names(db).includes?(table_name)
    # ignore if the requested table does not exist.
    env.response.status_code = 404
  else
    db.query "select * from #{table_name}" do |rs|
      col_names = rs.column_names
      rs.each do
        write_ndjson(env.response.output, col_names, rs)
        # force chunked response even on small tables
        env.response.output.flush
      end
    end
  end
end

def write_ndjson(io, col_names, rs)
  JSON.build(io) do |json|
    json.object do
      col_names.each do |col|
        json_encode_field json, col, rs.read
      end
    end
  end
  io << "\n"
end

def json_encode_field(json, col, value)
  case value
  when Bytes
    # custom json encoding. Avoid extra allocations.
    json.field col do
      json.array do
        value.each do |e|
          json.scalar e
        end
      end
    end
  when NotSupported
    # do not include the column as a json field.
  else
    # encode the value as their built in json format.
    json.field col do
      value.to_json(json)
    end
  end
end

alias NotSupported = PG::Geo::Point | PG::Geo::Box | PG::Geo::Circle |
                     PG::Geo::Line | PG::Geo::LineSegment | PG::Geo::Path |
                     PG::Geo::Polygon | PG::Numeric |
                     Array(PG::BoolArray) | Array(PG::CharArray) | Array(PG::Float32Array) |
                     Array(PG::Float64Array) | Array(PG::Int16Array) | Array(PG::Int32Array) |
                     Array(PG::Int64Array) | Array(PG::StringArray) | Char | JSON::Any

Kemal.run
db.close
