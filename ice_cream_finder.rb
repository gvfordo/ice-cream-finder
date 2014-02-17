require 'json'
require 'addressable/uri'
require 'rest-client'
require 'nokogiri'


SUPER_SECRET_API_KEY = File.read("secret_key.txt")

class IceCreamFinder

  def initialize
    @start_coord = get_lat_long
    @destination_coord = find_places
    print_directions
  end

  def find_user_location
    puts "Please enter your address: "
    street_address = gets.chomp
  end

  def geocode_request
    query = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/geocode/json",
      :query_values => {
        :address => find_user_location,
        :sensor => false,
        :key => SUPER_SECRET_API_KEY
      }
    ).to_s
  end

  def places_request
    query = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/place/nearbysearch/json",
      :query_values => {
        :location => @start_coord,
        :keyword => "ice cream",
        :sensor => false,
        :rankby => "distance",
        :key => SUPER_SECRET_API_KEY
      }
    ).to_s
  end

  def directions_query
    query = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/directions/json",
      :query_values => {
        :origin => @start_coord,
        :destination => @destination_coord,
        :sensor => false,
        :mode => "walking"
      }
    ).to_s
  end

  def get_lat_long
    location_result = JSON.parse(RestClient.get(geocode_request))
    location =  location_result["results"][0]["geometry"]["location"]
    lat = location["lat"]
    long = location["lng"]
    "#{lat}, #{long}"
  end

  def find_places
    location_result = JSON.parse(RestClient.get(places_request))
    @name = location_result["results"].first["name"]
    @destination_address = location_result["results"].first["vicinity"]
    location = location_result["results"].first["geometry"]["location"]

    lat =  location["lat"]
    long = location["lng"]
    "#{lat}, #{long}"
  end


  def give_directions
    JSON.parse(RestClient.get(directions_query))
  end

  def print_directions
    directions = give_directions
    puts "Let's take a walk to #{@name}! Located at #{@destination_address}"
    directions["routes"][0]["legs"][0]["steps"].each_with_index do |step, idx|
      parsed_html = Nokogiri::HTML(step["html_instructions"])
      puts "Step #{idx + 1} = #{parsed_html.text}"
    end
  end


end

i = IceCreamFinder.new
