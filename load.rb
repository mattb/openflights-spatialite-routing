require 'bundler'
Bundler.require
require 'csv'

db = SQLite3::Database.new "data/flights.sqlite"
db.enable_load_extension(1)
db.load_extension("/usr/local/lib/libspatialite.dylib")
db.execute("SELECT InitSpatialMetaData()")

puts "Loading airports..."
db.execute("create table airports (airport_id integer primary key, name varchar(255), city varchar(255), country varchar(255), iata char(3), icao char(4), latitude float, longitude float, altitude integer, timezone float, dst char(1))")
db.execute("SELECT AddGeometryColumn('airports', 'geom', 4326, 'POINT', 2);")
lines = 0
CSV.foreach("data/airports.dat") { |row|
  db.execute("INSERT INTO airports (airport_id,name,city,country,iata,icao,latitude,longitude,altitude,timezone,dst) VALUES(?,?,?,?,?,?,?,?,?,?,?)", *row)
  lines += 1
  if lines % 1000 == 0
    puts "Airports: #{lines}"
  end
}

puts "Loading routes..."
db.execute("create table routes (airline char(3), airline_id integer, source_airport char(4), source_airport_id integer, destination_airport char(4), destination_airport_id integer, codeshare char(1), stops integer, equipment text);")
db.execute("SELECT AddGeometryColumn('routes', 'geom', 4326, 'LINESTRING', 2);")
lines = 0
CSV.foreach("data/routes.dat") { |row|
  lat1, lng1 = db.execute("SELECT latitude, longitude FROM airports WHERE airport_id = #{row[3]}").first
  lat2, lng2 = db.execute("SELECT latitude, longitude FROM airports WHERE airport_id = #{row[5]}").first
  if !lat1.nil? and !lng1.nil? and !lat2.nil? and !lng2.nil?
    linestring = "GeomFromText('LINESTRING(#{lng1} #{lat1},#{lng2} #{lat2})', 4326)"
    sql = "INSERT INTO routes (airline,airline_id,source_airport,source_airport_id,destination_airport,destination_airport_id,codeshare,stops,equipment,geom) VALUES(?,?,?,?,?,?,?,?,?,#{linestring})"
    db.execute(sql, *row)
    lines += 1
    if lines % 1000 == 0
      puts "Routes: #{lines}"
    end
  end
}
db.execute("UPDATE routes SET stops = stops + 1")
db.close
`spatialite_network -d data/flights.sqlite -T routes -f source_airport_id -t destination_airport_id -c stops --unidirectional -g geom --output-table routes_stops_net_data --overwrite-output`
`spatialite_network -d data/flights.sqlite -T routes -f source_airport_id -t destination_airport_id --unidirectional -g geom --output-table routes_length_net_data --overwrite-output`
db = SQLite3::Database.new "data/flights.sqlite"
db.enable_load_extension(1)
db.load_extension("/usr/local/lib/libspatialite.dylib")
db.execute("CREATE VIRTUAL TABLE routes_stops_net USING VirtualNetwork('routes_stops_net_data');")
db.execute("CREATE VIRTUAL TABLE routes_length_net USING VirtualNetwork('routes_length_net_data');")
db.close
