require 'geocoder'
require 'pry-byebug'

module DespAirbnb
  module Calculations
    extend self

    ##
    # Distance between two points on Earth (Haversine formula).
    # Takes two points and an options hash.
    # The points are given in the same way that points are given to all
    # Geocoder methods that accept points as arguments. They can be:
    #
    # * an array of coordinates ([lat,lon])
    # * a geocodable address (string)
    # * a geocoded object (one which implements a +to_coordinates+ method
    #   which returns a [lat,lon] array
    #
    # The options hash supports:
    #
    # * <tt>:units</tt> - <tt>:mi</tt> or <tt>:km</tt>
    #   Use Geocoder.configure(:units => ...) to configure default units.
    #
    def distance_between(point1, point2, options = {})
      Geocoder::Calculations.distance_between(point1, point2, options)
    end

    def coord_float_to_string(coord) 
      coord.map! { |point| point.to_s }
    end

    def get_SW_NE_coordinates(coord, range)

      path = File.expand_path File.dirname(__FILE__) + "/python_function.py"

      #IO.popen: 1st arg is exactly what you would type into the command line to execute your python script.

      pythonPortal = IO.popen("python #{path}", "w+")
      pythonPortal.puts coord, range # anything you puts will be available to your python script from stdin
      pythonPortal.close_write
      result = []

      temp = pythonPortal.gets # everything your python script writes to stdout (usually using 'print') will be available using gets

      while temp != nil
          result << temp
          temp = pythonPortal.gets
      end 

      #result[0]/result[1] will be of form: "(26.0196deg, -80.2871deg) = (0.454127rad, -1.401275rad)\n"
      corner1 = [] 
      corner2 = []


      corner1 << result[0].gsub(/[()]/, "").split("=")[0].split(",")[0].strip.gsub(/[deg]/, "")
      corner1 << result[0].gsub(/[()]/, "").split("=")[0].split(",")[1].strip.gsub(/[deg]/, "")
      corner2 << result[1].gsub(/[()]/, "").split("=")[0].split(",")[0].strip.gsub(/[deg]/, "")
      corner2 << result[1].gsub(/[()]/, "").split("=")[0].split(",")[1].strip.gsub(/[deg]/, "")

      box = []
      box << corner1
      box << corner2
      # box will be in form: [["26.0196", "-80.2871"], ["26.1063", "-80.1906"]]

      box
    end

  end
end
