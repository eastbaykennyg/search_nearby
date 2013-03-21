#Write a script that takes your current location and finds nearby ice cream shops. It should provide directions to walk there.
require "rest-client"
require "json"
require "nokogiri"
require 'addressable/uri'
#Find current location

#http://maps.googleapis.com/maps/api/geocode/json?address=160+folsom+94105&sensor=false
#http://maps.googleapis.com/maps/api/geocode/json?location=160%2BFolsom%2BStreet%2B94105&sensor=false
#returns a json response


#search nearby places

# !!API KEY!!: AIzaSyBvgkKR3NrJVyzNRdvMLxWeqDJuNmxUe3k

#https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyBvgkKR3NrJVyzNRdvMLxWeqDJuNmxUe3k&location=37.78956840,-122.39189480&radius=500&keyword=ice+cream&sensor=false
#


#Directions to location

#https://maps.googleapis.com/maps/api/directions/json?origin=160+folsom+94105&destination=37.7955440,-122.3934480&sensor=false

#helper_function
def format_input(input)
  formatted_input = input.gsub(" ", "+")
end

#helper_function
def get_location(location)
  location = format_input(location)

  url = Addressable::URI.new(
        :scheme => "http",
        :host => "maps.googleapis.com",
        :path => "maps/api/geocode/json",
        :query_values => {
          :address => location.to_s,
          :sensor => false
        }).to_s

  response = RestClient.get(url)
  output = JSON.parse(response)
  lat = output["results"][0]["geometry"]["location"]["lat"]
  lng = output["results"][0]["geometry"]["location"]["lng"]
  "#{lat},#{lng}"
end

#helper_function #pass in non formatted inputs
def get_nearby_places(location, keyword, radius)
  keyw = format_input(keyword)
  location =  get_location(location)

  url = Addressable::URI.new(
        :scheme => "https",
        :host => "maps.googleapis.com",
        :path => "maps/api/place/nearbysearch/json",
        :query_values => {
          :key => "AIzaSyBvgkKR3NrJVyzNRdvMLxWeqDJuNmxUe3k",
          :location => location,
          :radius => radius,
          :keyword => keyw,
          :sensor => false
        }).to_s

  response = RestClient.get(url)
  output = JSON.parse(response)
  place1 = output["results"][0]
  place2 = output["results"][1]
  place3 = output["results"][2]
  [place1, place2, place3]
end

#helper_function
def get_place_info(place)
  name = place["name"]
  address = place["vicinity"]
  rating = place["rating"]
  is_open = place["opening_hours"]["open_now"]
  [name, address, rating, is_open]
end

def get_user_info
  puts "What is your current location"
  location = gets.chomp
  puts "What do you want to search for?"
  keyword = gets.chomp
  puts "What is your radius? (meters)"
  radius = gets.chomp
  [location, keyword, radius]
end

def search
  input = get_user_info
  location, keyword, radius = input[0], input[1], input[2]
  nearby_places = get_nearby_places(location, keyword, radius)
  display_results(nearby_places)
end

def display_results(places)
  places.each do |place|
  end
end


