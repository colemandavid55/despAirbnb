require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pry-byebug'
# require 'rack-flash'
require_relative 'lib/despAirbnb.rb'

class DespAirbnb::Server < Sinatra::Application

  set :bind, '0.0.0.0' # This is needed for Vagrant

  SW = 0
  NE = 1

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

  ##########################################
  #  # event stream stuff.
  ##########################################
  get '/rooms' do
    @route = params[:route] # <= Passed by Google Maps JS Frontend
    @range = params[:range]

    puts @route

    lastPoint = @route.first

    filteredRoute = @route.slice(1,route.length).select do |point|
      if (DespAirbnb::Calculations.distance_between(lastPoint, point, {units: :mi}) > @range)
        lastPoint = point
        true
      else
        false
      end
    end

    routeAreas = filteredRoute.map do |point|

    end

    # routeAreas = [
    #   [SW,NE]
    # ]

    allRooms = []
    allRoomIds = {}

    routeAreas.each do |area|
      EnsnareBnb.find_airbnb_hosts(sw: area[SW], ne: area[NE]).each do |room|
        if (!allRoomIds.has_key?(room[:id])) # Guearantee Unique
          allRooms.push(room)
          allRooms[room[:id]] = room[:id]
        end
      end
    end

    # allRooms = [
      # {
      #   lat: 
      #   lng:
      #   id:
      # }
    # ]
    DespAirbnb.get_rooms(allRooms)

    

    # Do the Rest of our calculations here
    # √ 2. Break the map GPS Coords into an array of coords that are all x-miles apart (Backend - ?)
    # 3. Create a south-east and north-west coord array given the above coord list (Backend - David)
    # √ 4. Query Ensnare_bnb for each one of the sw / nw coord sets ( Backend - Alex & James )
    # √ 5. Filter all data such that data 'id' is unique (This creates a hash)
    # √ 6. Pass filtered data to JS Frontend in @instance_variable as GPS Coordinates ()
  end

  get '/rooms/:id' do

  end

end
