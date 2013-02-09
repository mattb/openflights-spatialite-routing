require 'bundler'
Bundler.require
db = SQLite3::Database.new "data/flights.sqlite"
db.enable_load_extension(1)
db.load_extension("/usr/local/lib/libspatialite.dylib")

from_id = db.execute("SELECT airport_id FROM airports WHERE iata = ?", ARGV[0]).first
to_id = db.execute("SELECT airport_id FROM airports WHERE iata = ?", ARGV[1]).first

lineno = 0
puts "By least stops:"
puts
db.execute("SELECT * FROM routes_stops_net WHERE NodeFrom=? and NodeTo=?", from_id, to_id).map { |algorithm,arcRowid,nodeFrom,nodeTo,cost,geometry|
  iata1, city1 = db.execute("SELECT iata, city FROM airports WHERE airport_id = #{nodeFrom}").first
  iata2, city2 = db.execute("SELECT iata, city FROM airports WHERE airport_id = #{nodeTo}").first
  line = "#{iata1} #{city1} to #{iata2} #{city2}"
  puts line
  if lineno == 0
    puts "-" * (line.length)
  end
  lineno += 1
}
puts
puts "By shortest distance travelled:"
puts
lineno = 0
db.execute("SELECT * FROM routes_length_net WHERE NodeFrom=? and NodeTo=?", from_id, to_id).map { |algorithm,arcRowid,nodeFrom,nodeTo,cost,geometry|
  iata1, city1 = db.execute("SELECT iata, city FROM airports WHERE airport_id = #{nodeFrom}").first
  iata2, city2 = db.execute("SELECT iata, city FROM airports WHERE airport_id = #{nodeTo}").first
  line = "#{iata1} #{city1} to #{iata2} #{city2}"
  puts line
  if lineno == 0
    puts "-" * (line.length)
  end
  lineno += 1
}
