require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pry-byebug'
require 'ensnare_bnb'

# require 'rack-flash'
require_relative 'lib/despAirbnb.rb'

class DespAirbnb::Server < Sinatra::Application

  set :bind, '0.0.0.0' # This is needed for Vagrant

  SW = 0
  NE = 1

  @@allRooms = []

  configure do
    enable :sessions
    # use Rack::Flash
  end

  before do
  end

  # #
  # This is our only html view...
  #
  get '/' do
    erb :index
  end

  get '/dummy' do
    return DespAirbnb.build_dummy_rooms
  end

  ##########################################
  #  # event stream stuff.
  ##########################################
  post '/rooms' do
    @route = JSON.parse(params[:route]).to_a # <= Passed by Google Maps JS Frontend
    @range = params[:range].to_i
    @guests = params[:guests].to_i

    # @route = [ [30.250130000000002, -97.74995000000001], [31.12553, -97.33818000000001], [31.636650000000003, -97.09597000000001], [31.64316, -97.09656000000001], [32.40263, -96.87293000000001] ]
    # @range = 10

    #puts @route

    prevPoint = @route.first

    # filteredRoute = []
    filteredRoute = @route.slice(1,@route.length).select do |point|
      if (DespAirbnb::Calculations.distance_between(prevPoint, point, {units: :mi}) > @range)
        prevPoint = point
        true
      else
        false
      end
    end

    # puts filteredRoute
    filteredRoute.unshift(@route.first)

    # point = [LAT, LNG]
    routeAreas = filteredRoute.map do |point|
      point = DespAirbnb::Calculations.coord_float_to_string(point)
      DespAirbnb::Calculations.python_baby(point, @range)
    end

    # routeAreas = [
    #   [SW,NE]
    # ]

    @allRoomIds = {}

    puts "Number of routeAreas: #{routeAreas.length}"
    counter = 1
    routeAreas.each do |area|
      puts "Calulcating routeArea #{counter} . . ."
      counter+=1
      area[SW] = DespAirbnb::Calculations.coord_float_to_string(area[SW])
      area[NE] = DespAirbnb::Calculations.coord_float_to_string(area[NE])
      EnsnareBnb.find_airbnb_hosts(sw: area[SW], ne: area[NE]).each do |room|
        if (!@allRoomIds.has_key?(room[:id])) # Guearantee Unique
          # Check that it falls in the correct range . . .
          lat_upper_bound = area[NE][0].to_f
          lat_lower_bound = area[SW][0].to_f
          lng_upper_bound = area[NE][1].to_f
          lng_lower_bound = area[SW][1].to_f
          if (lat_upper_bound >= room[:latitude].to_f &&  lat_lower_bound <= room[:latitude].to_f &&
              lng_upper_bound >= room[:longitude].to_f && lng_lower_bound <= room[:longitude].to_f)
            @@allRooms.push(room)
            @allRoomIds[room[:id]] = room[:id]
          end 
        end
      end
    end

    # @allRooms = [
      # {
      #   lat: 
      #   lng:
      #   id:
      # }
    # ]
    #puts "got here"
    #puts @@allRooms
    DespAirbnb.get_rooms(@@allRooms).to_json

    # Do the Rest of our calculations here
    # √ 2. Break the map GPS Coords into an array of coords that are all x-miles apart (Backend - ?)
    # 3. Create a south-east and north-west coord array given the above coord list (Backend - David)
    # √ 4. Query Ensnare_bnb for each one of the sw / nw coord sets ( Backend - Alex & James )
    # √ 5. Filter all data such that data 'id' is unique (This creates a hash)
    # √ 6. Pass filtered data to JS Frontend in @instance_variable as GPS Coordinates ()
  end

  get '/rooms/:room_id' do

    room_id = params[:room_id]
    DespAirbnb.get_room(@@allRooms, room_id).to_json

  end

end
