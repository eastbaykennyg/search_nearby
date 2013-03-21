#Write a script that takes your current location and finds nearby ice cream shops. It should provide directions to walk there.
require "rest-client"
require "json"
require "nokogiri"

#Find current location

http://maps.googleapis.com/maps/api/geocode/json?address=160+folsom+94105&sensor=false
#returns a json response


#search nearby places

# !!API KEY!!: AIzaSyBvgkKR3NrJVyzNRdvMLxWeqDJuNmxUe3k

https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyBvgkKR3NrJVyzNRdvMLxWeqDJuNmxUe3k&location=37.78956840,-122.39189480&radius=500&keyword=ice+cream&sensor=false
#


#Directions to location

https://maps.googleapis.com/maps/api/directions/json?origin=160+folsom+94105&destination=37.7955440,-122.3934480&sensor=false

def format_location(location)
  formatted_loc = location.gsub(" ", "+")
end

def get_location(location)

  url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{location}&sensor=false"
  response = RestClient.get(url)
  output = JSON.parse(response)
  lat = output["results"][0]["geometry"]["location"]["lat"]
  lng = output["results"][0]["geometry"]["location"]["lng"]
  "#{lat},#{lng}"
end




