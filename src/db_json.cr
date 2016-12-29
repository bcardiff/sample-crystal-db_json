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

Kemal.run
db.close
