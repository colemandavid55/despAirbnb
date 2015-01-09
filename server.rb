require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pry-byebug'
# require 'rack-flash'
require_relative 'lib/despAirbnb.rb'

class DespAirbnb::Server < Sinatra::Application

  set :bind, '0.0.0.0' # This is needed for Vagrant

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
    @start = params[:location]
    @end = params[:destination]
    @guests = params[:guests]
    @range = params[:range]

    puts @start
    puts @end
    puts @guests
    puts @range
    # The following variables should be set
    # params[:start]
    # params[:end]

    # Do the Rest of our calculations here
    # 1. Query Google to Create a Map Without Hosts
    # 2. Break the map GPS Coords into an array of coords that are all x-miles apart
    # 3. Create a south-east and north-west coord array given the above coord list
    # 4. Query Ensnare_bnb for each one of the sw / nw coord sets
    # 5. Filter all data such that it's at least x-miles from coord, and data 'id' is unique (This creates a hash)
    # 6. Add filtered data to map as GPS Coordinates
    # 7. return new map so we can display it on the front end, else return status error
    
    erb :index
  end

end
