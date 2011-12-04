require 'rubygems'
require 'net/http'
require 'uri'
require 'couchrest'
require 'json'

COUCH_URL = "http://127.0.0.1:5984/loc4te/"

# establish db connection
$db = CouchRest.database!(COUCH_URL)

def handledata(postedData)
  json = JSON.parse(postedData)
  savedata(json)
  puts "Saved data for session " + session[:userid].to_s
end

def savedata(data)
  data['type'] = "geolocation"
  data['uuid'] = session[:userid]
  response = $db.save_doc(data)
end

def getrecentposts
  viewresult = $db.view('views/uuid_ts', {'limit' => 100, 'descending' => 'true', 'group_level' => '1' } )

  result = [];
  viewresult['rows'].each do |row|
    data = row['value']
    result << {'latitude' => data['lat'], 'longitude' => data['lon']}
  end

  result.to_json
end
