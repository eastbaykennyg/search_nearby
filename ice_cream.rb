#Write a script that takes your current location and finds nearby ice cream shops. It should provide directions to walk there.
require "rest-client"
require "json"
require "nokogiri"
require 'addressable/uri'

def format_input(input)
  formatted_input = input.gsub(" ", "+")
end


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
  puts
  [location, keyword, radius]
end

def search
  input = get_user_info
  location, keyword, radius = input[0], input[1], input[2]
  nearby_places = get_nearby_places(location, keyword, radius)
  display_results(nearby_places)
  puts "For what choice do you want directions for?"
  chosen_place = gets.chomp.to_i-1
  choice = nearby_places[chosen_place]
  directions(location, choice)

end

def display_results(places)
  places.each_with_index do |place, i|
    info = get_place_info(place)
    puts "Choice: #{i+1}"
    puts "Name: #{info[0]}"
    puts "Address: #{info[1]}"
    puts "Rating: #{info[2]}"
    puts "Open?: #{info[3]}"
    puts
  end
end


def directions(location, place)
  location = format_input(location)
  lat = place["geometry"]["location"]["lat"]
  lng = place["geometry"]["location"]["lng"]


  url = Addressable::URI.new(
        :scheme => "https",
        :host => "maps.googleapis.com",
        :path => "maps/api/directions/json",
        :query_values => {
          :origin => location,
          :destination => "#{lat},#{lng}",
          :sensor => false
        }).to_s

  response = RestClient.get(url)
  output = JSON.parse(response)
  steps = output["routes"][0]["legs"][0]["steps"]

  puts
  puts"---------------------------------------------"
  puts "Walking Directions"
  puts

  steps.each {|step| puts Nokogiri::HTML(step["html_instructions"]).text }
  puts
  puts"---------------------------------------------"
  nil

end

search